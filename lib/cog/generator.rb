module Cog
  
  # This module defines an interface which can be used by generator objects.
  # Specifically, it makes it easy to find ERB templates and render them into
  # generated source code files, using the {#stamp} method.
  #
  # @see https://github.com/ktonon/cog#generators Introduction to Generators
  module Generator
    
    autoload :FileMethods, 'cog/generator/file_methods'
    autoload :Filters, 'cog/generator/filters'
    autoload :LanguageMethods, 'cog/generator/language_methods'

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
    # @param template_path [String] path to template file relative to {Config#template_path}
    # @param destination [String] path to which the generated file should be written, relative to the {Config::ProjectConfig#project_path}
    # @option opt [Boolean] :absolute_template_path (false) is the +template_path+ absolute?
    # @option opt [Boolean] :absolute_destination (false) is the +destination+ absolute?
    # @option opt [Boolean] :once (false) if +true+, the file will not be updated if it already exists
    # @option opt [Binding] :binding (nil) an optional binding to use while evaluating the template
    # @option opt [String, Array<String>] :filter (nil) name(s) of {Filters}
    # @option opt [Boolean] :quiet (false) suppress writing to STDOUT?
    # @return [nil or String] if +destination+ is not provided, the stamped template is returned as a string
    def stamp(template_path, destination=nil, opt={})
      # Ignore destination if its a hash, its meant to be opt
      opt, destination = destination, nil if destination.is_a? Hash
      
      # Render and filter
      r = find_and_render template_path, opt
      r = filter_through r, opt[:filter]
      return r if destination.nil?

      # Place it in a file
      write_scratch_file(destination, r, opt[:absolute_destination]) do |path, scratch|
        if files_are_same?(path, scratch) || (opt[:once] && File.exists?(path))
          FileUtils.rm scratch
        else
          updated = File.exists? path
          FileUtils.mv scratch, path
          STDOUT.write "#{updated ? :Updated : :Created} #{path.relative_to_project_root}\n".color(updated ? :white : :green) unless opt[:quiet]
        end
      end
      nil
    end

    # Provide a value for embeds with the given hook
    # @param hook [String] hook name used in the embed statements
    # @yieldparam context [EmbedContext] provides information about the environment in which the embed statement was found
    # @yieldreturn The value which will be used to expand the embed (or replace the embedded content)
    # @return [nil]
    def embed(hook, &block)
      eaten = 0 # keep track of eaten statements so that the index can be adjusted
      Embeds.find(hook) do |c|
        c.eaten = eaten
        if Embeds.update c, &block
          eaten += 1 if c.once?
          STDOUT.write "Updated #{c.path.relative_to_project_root} - #{(c.index + 1).ordinalize} occurrence of embed '#{c.hook}'\n".color :white
        end
      end
    end
    
    private
    
    # @param template_path [String] path to template file relative one of the {Config#template_paths}
    # @option opt [Boolean] :absolute_template_path (false) is the +template_path+ absolute?
    # @option opt [Binding] :binding (nil) an optional binding to use while evaluating the template
    # @return [String] result of rendering the template
    def find_and_render(template_path, opt={})
      t = get_template template_path, :absolute => opt[:absolute_template_path]
      b = opt[:binding] || binding
      Cog.activate_language :ext => File.extname(template_path.to_s) do
        t.result(b)
      end
    end
    
    # @param text [String] text to run through filters
    # @param f [String, Array<String>] name(s) of {Filters}
    def filter_through(text, f)
      f = [f].compact unless f.is_a?(Array)
      f.each {|name| text = call_filter name, text }
      text
    end
    
    # @param original [String] path to the original file
    # @param text [String] text to write into the scratch file
    # @param absolute [Boolean] is the path absolute or relative to the project root?
    # @yieldparam original [String] absolute path to original file
    # @yieldparam scratch [String] path to the scratch file
    # @return [nil]
    def write_scratch_file(original, text, absolute=false, &block)
      path = absolute ? original : File.join(Cog.project_path, original)
      FileUtils.mkpath File.dirname(path) unless File.exists? path
      scratch = "#{path}.scratch"
      File.open(scratch, 'w') {|file| file.write text}
      block.call path, scratch
    end

    public
    
    extend self
    
  end
end
