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
      def initialize(config, path)
        @cogfile_context = {
          :config => config,
          :cogfile_path => path,
          :cogfile_dir => File.dirname(path),
        }
      end
    
      # Interpret the +Cogfile+ at {Config::ProjectMethods#cogfile_path}
      # @api developer
      # @return [nil]
      def interpret
        eval File.read(@cogfile_context[:cogfile_path]), binding
        nil
      end
    
      # Define a directory in which to find generators
      # @param path [String] a file system path
      # @param absolute [Boolean] if +false+, the path is relative to {Config::ProjectMethods#project_root}
      # @return [nil]
      def generator_path(path, absolute=false)
        path = File.join @cogfile_context[:cogfile_dir], path unless absolute
        config_eval { @generator_path << path }
        nil
      end

      # Define a directory in which to find templates
      # @param path [String] a file system path
      # @param absolute [Boolean] if +false+, the path is relative to {Config::ProjectMethods#project_root}
      # @return [nil]
      def template_path(path, absolute=false)
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
        raise Errors::PluginPathDoesNotExist.new path unless File.exists?(path)
        raise Errors::PluginPathIsNotADirectory.new path unless File.directory?(path)
        @cogfile_context[:config].register_plugins path
        nil
      end

      # Define the directory in which to generate code
      # @param path [String] a file system path to a directory
      # @param absolute [Boolean] if +false+, the path is relative to {Config::ProjectMethods#project_root}
      # @return [nil]
      def project_path(path, absolute=false)
        path = File.join @cogfile_context[:cogfile_dir], path unless absolute
        config_eval { @project_path = path }
        nil
      end

      # Explicitly specify a mapping from file extensions to languages
      # @param map [Hash] key-value pairs from this mapping will override the default language map supplied by +cog+
      # @return [nil]
      def language_extensions(map)
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
        dsl = LanguageDSL.new key
        r = block.call dsl
        lang = dsl.finalize
        config_eval do
          @language[lang.key] = lang
        end
        r
      end

      # Define a block to call when stamping a generator
      # @yieldparam name [String] name of the generator to stamp
      # @yieldparam dest [String] file system path where the file will be created
      # @yieldreturn [nil]
      # @return [nil]
      def stamp_generator(&block)
        config_eval do
          @stamp_generator_block = block
        end
      end

      private
      
      def config_eval(&block)
        @cogfile_context[:config].instance_eval &block
      end
    end
  end
end
