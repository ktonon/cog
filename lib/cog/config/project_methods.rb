module Cog
  module Config

    # {Config} methods related to projects
    module ProjectMethods
      
      # @return [String] path to the project's {Cogfile}
      attr_reader :cogfile_path

      # @return [Array<String>] directories in which to find generators
      attr_reader :generator_path

      # @return [String] directory in which the project's {Cogfile} is found
      attr_reader :project_root
    
      # @return [String] directory to which project source code is generated
      attr_reader :project_path

      # @return [Array<String>] directories in which to find templates
      attr_reader :template_path
      
      # @return [Boolean] whether or not we operating in the context of a project
      def project?
        !@project_root.nil?
      end

      # @return [Array<String>] list of paths to files in the {#project_path} which are written in a supported language
      def supported_project_files
        exts = Cog.language_extensions.join ','
        Dir.glob "#{Cog.project_path}/**/*.{#{exts}}"
      end
      
    end
  end
end