module Cog
  class Config
    
    # In your project's +Cogfile+, +self+ has been set to an instance of this class.
    #
    # ==== Example +Cogfile+
    #   project_generators_path 'cog/generators'
    #   project_templates_path 'cog/templates'
    #   project_source_path 'src'
    #   language 'c++'
    #
    # Typing `cog init` will create a +Cogfile+ in the present working directory.
    #
    # +Cogfile+ files are used to configure an instance of Config.
    class Cogfile
    
      def initialize(config) # :nodoc:
        @config = config
      end
    
      # Interpret the Cogfile and initialize @config
      def interpret # :nodoc:
        eval File.read(@config.cogfile_path), binding
      rescue Exception => e
        raise CogfileError.new(e.to_s)
      end
    
      # Define the directory in which to find project generators
      # ==== Arguments
      # * +path+ - A file system path
      # * +absolute+ - If false, the path is relative to the directory containing the +Cogfile+
      def project_generators_path(path, absolute=false)
        @config.instance_eval do
          @project_generators_path = absolute ? path : File.join(project_root, path)
        end
      end

      # Define the directory in which to find custom project templates
      # ==== Arguments
      # * +path+ - A file system path
      # * +absolute+ - If false, the path is relative to the directory containing the +Cogfile+
      def project_templates_path(path, absolute=false)
        @config.instance_eval do
          @project_templates_path = absolute ? path : File.join(project_root, path)
        end
      end

      # Define the directory to which project source code is generated
      # ==== Arguments
      # * +path+ - A file system path
      # * +absolute+ - If false, the path is relative to the directory containing the +Cogfile+
      def project_source_path(path, absolute=false)
        @config.instance_eval do
          @project_source_path = absolute ? path : File.join(project_root, path)
        end
      end

      # Define the default language in which to generated application source code
      # ==== Arguments
      # * +lang+ - A code for the language. Acceptable values are <tt>c++</tt>.
      def language(lang)
        @config.instance_eval do
          @language = lang
        end
      end
    end

    # For wrapping errors which occur during the processing of a +Cogfile+.
    class CogfileError < StandardError
      def message
        "in Cogfile, " + super
      end
    end
    
  end
end
