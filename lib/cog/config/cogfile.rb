require 'active_support/core_ext'
require 'cog/languages'

module Cog
  class Config
    
    # In your project's +Cogfile+, +self+ has been set to an instance of this class.
    #
    # Typing <tt>cog init</tt> will create a +Cogfile+ in the present working directory.
    # +Cogfile+ files are used to configure an instance of {Config}.
    #
    # @example
    #   project_generators_path 'cog/generators'
    #   project_templates_path 'cog/templates'
    #   project_source_path 'src'
    #   language 'c++'
    #
    class Cogfile
      
      # Initialize with an instance of {Config}
      # @api developer
      # @param config [Config] the object which will be configured by this Cogfile
      def initialize(config)
        @config = config
      end
    
      # Interpret the +Cogfile+ at {Config#cogfile_path}
      # @api developer
      # @return [nil]
      def interpret
        eval File.read(@config.cogfile_path), binding
        nil
      rescue Exception => e
        raise CogfileError.new(e.to_s)
      end
    
      # Define the directory in which to find project generators
      # @param path [String] a file system path
      # @param absolute [Boolean] if +false+, the path is relative to {Config#project_root}
      # @return [nil]
      def project_generators_path(path, absolute=false)
        @config.instance_eval do
          @project_generators_path = absolute ? path : File.join(project_root, path)
        end
        nil
      end

      # Define the directory in which to find custom project templates
      # @param path [String] a file system path
      # @param absolute [Boolean] if +false+, the path is relative to {Config#project_root}
      # @return [nil]
      def project_templates_path(path, absolute=false)
        @config.instance_eval do
          @project_templates_path = absolute ? path : File.join(project_root, path)
        end
        nil
      end

      # Define the directory to which project source code is generated
      # @param path [String] a file system path
      # @param absolute [Boolean] if +false+, the path is relative to {Config#project_root}
      # @return [nil]
      def project_source_path(path, absolute=false)
        @config.instance_eval do
          @project_source_path = absolute ? path : File.join(project_root, path)
        end
        nil
      end

      # Explicitly specify a mapping from file extensions to languages
      # @param map [Hash] key-value pairs from this mapping will override the default language map supplied by +cog+
      # @return [nil]
      def language_extensions(map)
        @config.instance_eval do
          @language_extension_map.update map
        end
        nil
      end
      
      # Define the target language which should be used when
      # creating generators, and no language is explicitly specified
      # @param lang_id [String] a language identifier
      def default_target_language(lang_id)
        @config.instance_eval do
          @target_language = Cog::Languages.get_language(lang_id)
        end
      end
    end

    # For wrapping errors which occur during the processing of a {Cogfile}
    class CogfileError < StandardError
      def message
        "in Cogfile, " + super
      end
    end
    
  end
end
