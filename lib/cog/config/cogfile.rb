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
      def interpret
        eval File.read(@config.cogfile_path), binding
      rescue Exception => e
        raise CogfileError.new(e.to_s)
      end
    
      # Define the directory in which to find project generators
      # @param path [String] a file system path
      # @param absolute [Boolean] if +false+, the path is relative to {Config#project_root}
      def project_generators_path(path, absolute=false)
        @config.instance_eval do
          @project_generators_path = absolute ? path : File.join(project_root, path)
        end
      end

      # Define the directory in which to find custom project templates
      # @param path [String] a file system path
      # @param absolute [Boolean] if +false+, the path is relative to {Config#project_root}
      def project_templates_path(path, absolute=false)
        @config.instance_eval do
          @project_templates_path = absolute ? path : File.join(project_root, path)
        end
      end

      # Define the directory to which project source code is generated
      # @param path [String] a file system path
      # @param absolute [Boolean] if +false+, the path is relative to {Config#project_root}
      def project_source_path(path, absolute=false)
        @config.instance_eval do
          @project_source_path = absolute ? path : File.join(project_root, path)
        end
      end

      # Define the default language in which to generated application source code
      # @param lang [String] a code for the language. Acceptable values are <tt>c++</tt>
      def language(lang)
        @config.instance_eval do
          @language = lang
        end
      end
    end

    # For wrapping errors which occur during the processing of a {Cogfile}
    # @api client
    class CogfileError < StandardError
      def message
        "in Cogfile, " + super
      end
    end
    
  end
end
