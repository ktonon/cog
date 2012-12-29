module Cog
  module Config

    # {Config} methods related to projects
    module ProjectConfig
      
      # @return [String] path to the project's {DSL::Cogfile}
      attr_reader :project_cogfile_path

      # @return [String] directory in which to place generated output. For example, the +destination+ parameter of {Generator#stamp} is relative to this path.
      attr_reader :project_path

      # @return [String] directory in which the project's {DSL::Cogfile} is found
      attr_reader :project_root
    
      # @return [String,nil] directory in which to place project generators
      attr_reader :project_generator_path

      # @return [String,nil] directory in which to place project plugins
      attr_reader :project_plugin_path

      # @return [String,nil] directory in which to place project templates
      attr_reader :project_template_path
      
      # @return [Boolean] whether or not we operating in the context of a project
      def project?
        !@project_root.nil?
      end

      # @return [Array<String>] list of paths to files in the {#project_path} which are written in a supported language
      def supported_project_files
        if project?
          exts = Cog.language_extensions.join ','
          Dir.glob "#{Cog.project_path}/**/*.{#{exts}}"
        else
          []
        end
      end
      
      private
      
      def path_if_for_project(path)
        path if path && path.start_with?(@project_root)
      end
      
    end
  end
end