module Cog
  module DSL
    
    # In your project's +Cogfile+, +self+ has been set to an instance of this class.
    # Typing <tt>cog init</tt> will create a +Cogfile+ in the present working directory.
    class Cogfile
      
      include Generator
      
      # Initialize with an instance of {Config}
      # @api developer
      # @param config [Config] the object which will be configured by this Cogfile
      # @param path [String] path to the cogfile
      # @option opt [Boolean] :project (false) is this the project cogfile?
      # @option opt [Boolean] :plugin_path_only (false) only process +plugin_path+ calls in the given cogfile
      # @option opt [Plugin] :plugin (nil) indicate that the cogfile is for the given plugin
      def initialize(config, path, opt={})
        @cogfile_context = {
          :config => config,
          :cogfile_path => path,
          :cogfile_dir => File.dirname(path),
          :project => opt[:project],
          :plugin_path_only => opt[:plugin_path_only],
          :plugin => opt[:plugin],
        }
      end
    
      # Interpret the +Cogfile+ at {Config::ProjectConfig#cogfile_path}
      # @api developer
      # @return [nil]
      def interpret
        eval File.read(cogfile_path), binding
        nil
      end
    
      # Define the directory in which to generate code
      # @param path [String] a file system path to a directory
      # @param absolute [Boolean] if +false+, the path is relative to {Config::ProjectConfig#project_root}
      # @return [nil]
      def project_path(path, absolute=false)
        return if @cogfile_context[:plugin_path_only]
        path = File.join @cogfile_context[:cogfile_dir], path unless absolute
        config_eval { @project_path = path }
      end

      # Define a directory in which to find generators
      # @param path [String] a file system path
      # @param absolute [Boolean] if +false+, the path is relative to {Config::ProjectConfig#project_root}
      # @return [nil]
      def generator_path(path, absolute=false)
        return if @cogfile_context[:plugin_path_only]
        add_config_path :generator, path, absolute
      end

      # Define a directory in which to find templates
      # @param path [String] a file system path
      # @param absolute [Boolean] if +false+, the path is relative to {Config::ProjectConfig#project_root}
      # @return [nil]
      def template_path(path, absolute=false)
        return if @cogfile_context[:plugin_path_only]
        add_config_path :template, path, absolute
      end
      
      # Define a directory in which to find plugins
      # @param path [String] a file system path
      # @param absolute [Boolean] if +false+, the path is relative to {Config::ProjectConfig#project_root}
      # @return [nil]
      def plugin_path(path, absolute=false)
        path = add_config_path :plugin, path, absolute
        if path && File.exists?(path)
          raise Errors::PluginPathIsNotADirectory.new path unless File.directory?(path)
          @cogfile_context[:config].register_plugins path
        end
      end

      # Explicitly specify a mapping from file extensions to languages
      # @param map [Hash] key-value pairs from this mapping will override the default language map supplied by +cog+
      # @return [nil]
      def language_extensions(map)
        return if @cogfile_context[:plugin_path_only]
        config_eval do
          map.each_pair do |key, value|
            @language_extension_map[key.to_s.downcase] = value.to_s.downcase
          end
        end
      end
      
      # Define and register a language with cog
      # @param key [String] unique case-insensitive identifier
      # @yieldparam lang [LanguageDSL] an interface for defining the language
      # @return [Object] the return value of the block
      def language(key, &block)
        return if @cogfile_context[:plugin_path_only]
        dsl = LanguageDSL.new key
        r = block.call dsl
        lang = dsl.finalize
        config_eval do
          @language[lang.key] = lang
        end
        r
      end

      # Register an autoload variable in the class {GeneratorSandbox}. That way when generators are run as instances of a sandbox, they will be able to load plugins just by referencing them using the provided +identifier_name+.
      # @param identifier_name [String] identifier by which the plugin can be referenced in generators
      # @param path [String] path to the ruby file to load when the identifier is referenced (relative to the cogfile)
      # @return [nil]
      def autoload_plugin(identifier_name, path)
        GeneratorSandbox.autoload_plugin(identifier_name, File.join(@cogfile_context[:plugin].path, path))
      end
      
      # Define a block to call when stamping a generator for a plugin. A call to this method should only be used in plugin cogfiles.
      # @yieldparam name [String] name of the generator to stamp
      # @yieldparam dest [String] file system path where the file will be created
      # @yieldreturn [nil]
      # @return [nil]
      def stamp_generator(&block)
        @cogfile_context[:plugin].stamp_generator_block = block
      end
      
      private
      
      def cogfile_path
        @cogfile_context[:cogfile_path]
      end

      # @return [nil]
      def config_eval(&block)
        @cogfile_context[:config].instance_eval &block
        nil
      end
      
      # @return [String,nil] absolute path
      def add_config_path(name, path, absolute)
        return if path.nil?
        path = File.join @cogfile_context[:cogfile_dir], path unless absolute
        is_project = @cogfile_context[:project]
        config_eval do
          instance_variable_set("@project_#{name}_path", path) if is_project
          instance_variable_get("@#{name}_path") << path
        end
        path
      end
    end
  end
end
