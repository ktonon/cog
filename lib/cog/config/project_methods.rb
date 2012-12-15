module Cog
  module Config

    # {Config} methods related to projects
    module ProjectMethods
      
      # @return [String] path to the project's {Cogfile}
      attr_reader :cogfile_path

      # @return [String] directory in which to find project generators
      attr_reader :project_generators_path

      # @return [String] directory in which the project's {Cogfile} is found
      attr_reader :project_root
    
      # @return [String] directory to which project source code is generated
      attr_reader :project_source_path

      # @return [String] directory in which to find custom project templates
      attr_reader :project_templates_path
      
      # @return [Boolean] whether or not we operating in the context of a project
      def project?
        !@project_root.nil?
      end

      # @return [Array<String>] list of paths to files in the {#project_source_path} which are written in a supported language
      def supported_project_files
        exts = Cog.language_extensions.join ','
        Dir.glob "#{Cog.project_source_path}/**/*.{#{exts}}"
      end
      
    end
  end
end