require 'cog/config'
require 'cog/errors'
require 'cog/generator/file_methods'
require 'cog/generator/filters'
require 'cog/generator/language_methods'
require 'cog/helpers'
require 'erb'
require 'rainbow'

module Cog
  
  # This module defines an interface which can be used by generator objects.
  # Specifically, it makes it easy to find ERB templates and render them into
  # generated source code files, using the {#stamp} method.
  #
  # @see https://github.com/ktonon/cog#generators Introduction to Generators
  module Generator

    include FileMethods
    include Filters
    include LanguageMethods

    # @api developer
    # @return [Hash] Generator context. Generator methods should place context into here instead of instance variables to avoid polluting the instance variable name space
    def gcontext
      if @generator_context.nil?
        @generator_context = {
          :scopes => []
        }
      end
      @generator_context
    end
    
    # Stamp a template into a file or return it as a string
    # @param template_path [String] path to template file relative one of the {Config#template_paths}
    # @param destination [String] path to which the generated file should be written, relative to the {Config#project_source_path}
    # @option opt [Boolean] :absolute_template_path (false) is the +template_path+ absolute?
    # @option opt [Boolean] :absolute_destination (false) is the +destination+ absolute?
    # @option opt [String, Array<String>] :filter (nil) filter the result through the named methods
    # @option opt [Boolean] :quiet (false) suppress writing to STDOUT?
    # @return [nil or String] if +destination+ is not provided, the stamped template is returned as a string
    def stamp(template_path, destination=nil, opt={})
      # Ignore destination if its a hash, its meant to be opt
      opt, destination = destination, nil if destination.is_a? Hash
      
      # Find and render the template
      t = get_template template_path, :absolute => opt[:absolute_template_path]
      b = opt[:binding] || binding
      r = Config.instance.activate_language :ext => File.extname(template_path.to_s) do
        t.result(b)
      end
      
      # Run r through filters
      f = opt[:filter]
      f = [f].compact unless f.is_a?(Array)
      f.each {|name| r = call_filter name, r }
      
      return r if destination.nil?

      # Place it in a file
      dest = opt[:absolute_destination] ? destination : File.join(Config.instance.project_source_path, destination)
      FileUtils.mkpath File.dirname(dest) unless File.exists? dest
      scratch = "#{dest}.scratch"
      File.open(scratch, 'w') {|file| file.write r}
      if files_are_same? dest, scratch
        FileUtils.rm scratch
      else
        updated = File.exists? dest
        FileUtils.mv scratch, dest
        STDOUT.write "#{updated ? :Updated : :Created} #{dest.relative_to_project_root}\n".color(updated ? :white : :green) unless opt[:quiet]
      end
      nil
    end

    # Provide a value for the snippet with the given key
    # @param key [String] a unique identifier for the snippet
    # @yield The return value of the provided block will be used to expand the snippet
    # @return [nil]
    def snippet(key, &block)
      Project.snippet_directives(key) do |filename, index|
        if Project.update_snippet_expansion key, filename, index, block.call
          STDOUT.write "Updated #{filename.relative_to_project_root} - #{(index + 1).ordinalize} occurrence of snippet '#{key}'\n".color :white
        end
      end
    end

  end
end
