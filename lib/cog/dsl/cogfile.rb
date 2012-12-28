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
      # @option opt [Boolean] :plugin_path_only (false) only process +plugin_path+ calls in the given cogfile
      # @option opt [Plugin] :plugin (nil) indicate that the cogfile is for the given plugin
      def initialize(config, path, opt={})
        @cogfile_context = {
          :config => config,
          :cogfile_path => path,
          :cogfile_dir => File.dirname(path),
          :plugin_path_only => opt[:plugin_path_only],
          :plugin => opt[:plugin],
        }
      end
    
      # Interpret the +Cogfile+ at {Config::ProjectMethods#cogfile_path}
      # @api developer
      # @return [nil]
      def interpret
        eval File.read(cogfile_path), binding
        nil
      end
    
      # Define a directory in which to find generators
      # @param path [String] a file system path
      # @param absolute [Boolean] if +false+, the path is relative to {Config::ProjectMethods#project_root}
      # @return [nil]
      def generator_path(path, absolute=false)
        return if @cogfile_context[:plugin_path_only]
        path = File.join @cogfile_context[:cogfile_dir], path unless absolute
        config_eval { @generator_path << path }
        nil
      end

      # Define a directory in which to find templates
      # @param path [String] a file system path
      # @param absolute [Boolean] if +false+, the path is relative to {Config::ProjectMethods#project_root}
      # @return [nil]
      def template_path(path, absolute=false)
        return if @cogfile_context[:plugin_path_only]
        path = File.join @cogfile_context[:cogfile_dir], path unless absolute
        config_eval { @template_path << path }
        nil
      end
      
      # Define a directory in which to find plugins
      # @param path [String] a file system path
      # @param absolute [Boolean] if +false+, the path is relative to {Config::ProjectMethods#project_root}
      # @return [nil]
      def plugin_path(path, absolute=false)
        path = File.join @cogfile_context[:cogfile_dir], path unless absolute
        raise Errors::PluginPathIsNotADirectory.new path if File.exists?(path) && !File.directory?(path)
        config_eval { @plugin_path << path }
        if File.exists?(path)
          @cogfile_context[:config].register_plugins path
        end
        nil
      end

      # Define the directory in which to generate code
      # @param path [String] a file system path to a directory
      # @param absolute [Boolean] if +false+, the path is relative to {Config::ProjectMethods#project_root}
      # @return [nil]
      def project_path(path, absolute=false)
        return if @cogfile_context[:plugin_path_only]
        path = File.join @cogfile_context[:cogfile_dir], path unless absolute
        config_eval { @project_path = path }
        nil
      end

      # Explicitly specify a mapping from file extensions to languages
      # @param map [Hash] key-value pairs from this mapping will override the default language map supplied by +cog+
      # @return [nil]
      def language_extensions(map)
        return if @cogfile_context[:plugin_path_only]
        config_eval do
          map.each_pair do |key, value|
            @language_extension_map[key.to_s.downcase] = value
          end
        end
        nil
      end
      
      # Define and register a language with cog
      # @param key [String] unique case-insensitive identifier
      # @yieldparam lang_def [LanguageDefinition] an interface for defining the language
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

      # Register an autoload variable 
      def autoload_plugin(name, path)
        raise Errors::NotAPluginCogfile.new cogfile_path unless @cogfile_context[:plugin]
        GeneratorSandbox.autoload_plugin(name, File.join(@cogfile_context[:plugin].path, path))
      end
      
      # Define a block to call when stamping a generator
      # @yieldparam name [String] name of the generator to stamp
      # @yieldparam dest [String] file system path where the file will be created
      # @yieldreturn [nil]
      # @return [nil]
      def stamp_generator(&block)
        raise Errors::NotAPluginCogfile.new cogfile_path unless @cogfile_context[:plugin]
        @cogfile_context[:plugin].stamp_generator_block = block
      end
      
      def cogfile_path
        @cogfile_context[:cogfile_path]
      end

      private
      
      def config_eval(&block)
        @cogfile_context[:config].instance_eval &block
      end
      
    end
  end
end
