require 'cog/config'
require 'cog/errors'
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

    # List the available project generators
    # @param verbose [Boolean] should full generator paths be listed?
    # @return [Array<String>] a list of generator names
    def self.list(verbose=false)
      if Config.instance.project?
        x = Dir.glob(File.join Config.instance.project_generators_path, '*.rb')
        verbose ? x : (x.collect {|path| File.basename(path).slice(0..-4)})
      else
        []
      end
    end
    
    # Create a new generator
    # @param name [String] the name to use for the new generator
    # @option opt [String] :tool ('basic') the name of the tool to use
    # @return [Boolean] was the generator successfully created?
    def self.create(name, opt={})
      return false unless Config.instance.project?

      gen_name = File.join Config.instance.project_generators_path, "#{name}.rb"
      if File.exists? gen_name
        STDERR.write "Generator '#{gen_name}' already exists\n".color(:red)
        return false
      end

      tool = (opt[:tool] || :basic).to_s
      template_name = File.join Config.instance.project_templates_path, "#{name}.txt.erb"
      if tool == 'basic' && File.exists?(template_name)
        STDERR.write "Template '#{template_name}' already exists\n".color(:red)
        return false
      end
      
      Object.new.instance_eval do
        extend Generator
        @name = name
        @class_name = name.to_s.camelize
        if tool == 'basic'
          stamp 'cog/generator/basic.rb', gen_name, :absolute_destination => true
          stamp 'cog/generator/basic-template.txt.erb', template_name, :absolute_destination => true
        else
          tool_path = Tool.find(tool)
          if tool_path.nil?
            STDERR.write "No such tool '#{tool}'"
            false
          else
            require tool_path
            @absolute_require = tool_path != tool
            @tool_parent_path = File.dirname(tool_path)
            stamp Config.instance.tool_generator_template, gen_name, :absolute_destination => true
            true
          end
        end
      end
    end
    
    # Run the generator with the given name
    # @param name [String] name of the generator as returned by {Generator.list}
    # @option opt [Boolean] :verbose (false) in the case of an exception, should a full stack trace be written?
    # @return [Boolean] was the generator run successfully?
    def self.run(name, opt={})
      filename = File.join Cog::Config.instance.project_generators_path, "#{name}.rb"
      if File.exists? filename
        require filename
        return true
      end
      STDERR.write "No such generator '#{name}'\n".color(:red)
      false
    rescue => e
      trace = opt[:verbose] ? "\n#{e.backtrace.join "\n"}" : ''
      STDERR.write "Generator '#{name}' failed: #{e}#{trace}\n".color(:red)
      false
    end

    # Get the template with the given name
    # @param path [String] path to template file relative one of the {Config#template_paths}
    # @option opt [Boolean] :absolute (false) is the +path+ argument absolute?
    # @return [ERB] an instance of {http://ruby-doc.org/stdlib-1.9.3/libdoc/erb/rdoc/ERB.html ERB}
    def get_template(path, opt={})
      path += '.erb'
      fullpath = if opt[:absolute]
        path
      else
        Config.instance.template_paths.inject('') do |found, prefix|
          x = File.join prefix, path
          found.empty? && File.exists?(x) ? x : found
        end
      end
      raise Errors::MissingTemplate.new path unless File.exists? fullpath
      ERB.new File.read(fullpath), 0, '>'
    end
    
    # Stamp a template into a file or return it as a string
    # @param template_path [String] path to template file relative one of the {Config#template_paths}
    # @param destination [String] path to which the generated file should be written, relative to the {Config#project_source_path}
    # @option opt [Boolean] :absolute_template_path (false) is the +template_path+ absolute?
    # @option opt [Boolean] :absolute_destination (false) is the +destination+ absolute?
    # @option opt [Boolean] :quiet (false) suppress writing to STDOUT?
    # @return [nil or String] if +destination+ is not provided, the stamped template is returned as a string
    def stamp(template_path, destination=nil, opt={})
      t = get_template template_path, :absolute => opt[:absolute_template_path]
      b = opt[:binding] || binding
      return t.result(b) if destination.nil?
      
      dest = opt[:absolute_destination] ? destination : File.join(Config.instance.project_source_path, destination)
      FileUtils.mkpath File.dirname(dest) unless File.exists? dest
      scratch = "#{dest}.scratch"
      File.open(scratch, 'w') {|file| file.write t.result(b)}
      if same? dest, scratch
        FileUtils.rm scratch
      else
        updated = File.exists? dest
        FileUtils.mv scratch, dest
        STDOUT.write "#{updated ? :Updated : :Created} #{dest.relative_to_project_root}\n".color(updated ? :white : :green) unless opt[:quiet]
      end
      nil
    end

    # Copy a file from +src+ to +dest+, but only if +dest+ does not already exist.
    # @param src [String] where to copy from
    # @param dest [String] where to copy to
    # @option opt [Boolean] :quiet (false) suppress writing to STDOUT?
    # @return [nil]
    def copy_if_missing(src, dest, opt={})
      unless File.exists? dest
        FileUtils.cp src, dest
        STDOUT.write "Created #{dest.relative_to_project_root}\n".color(:green) unless opt[:quiet]
      end
    end

    # Recursively create directories in the given path if they are missing.
    # @param path [String] a file system path representing a directory
    # @option opt [Boolean] :quiet (false) suppress writing to STDOUT?
    # @return [nil]
    def touch_path(path, opt={})
      unless File.exists? path
        FileUtils.mkdir_p path
        STDOUT.write "Created #{path.relative_to_project_root}\n".color(:green) unless opt[:quiet]
      end
      nil
    end
    
    # File extension for a snippet of the given source code language.
    # @api unstable
    # @example
    #   snippet_extension 'c++' # => 'h'
    def snippet_extension(lang = 'text') # :nodoc:
      case lang
      when /(c\+\+|c|objc)/i
        'h'
      else
        'txt'
      end
    end

    # @api unstable
    def include_guard_begin(name)
      full = "COG_INCLUDE_GUARD_#{name.upcase}"
      "#ifndef #{full}\n#define #{full}"
    end
    
    # @api unstable
    def include_guard_end
      "#endif // COG_INCLUDE_GUARD_[...]"
    end
    
    # @api unstable
    def namespace_begin(name)
      return if name.nil?
      case Config.instance.language
      when /c\+\+/
        "namespace #{name} {"
      end
    end

    # @api unstable
    def namespace_end(name)
      return if name.nil?
      case Config.instance.language
      when /c\+\+/
        "} // namespace #{name}"
      end
    end
    
  private
    def same?(original, scratch)
      if File.exists? original
        File.read(original) == File.read(scratch)
      else
        false
      end
    end

  end
end
