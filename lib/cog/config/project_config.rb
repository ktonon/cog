module Cog
  module Config

    # {Config} methods related to projects
    module ProjectConfig
      
      # @return [String] path to the project's {Cogfile}
      attr_reader :project_cogfile_path

      # @return [String] directory to which to place generated output
      attr_reader :project_path

      # @return [String] directory in which the project's {Cogfile} is found
      attr_reader :project_root
    
      # @return [Boolean] whether or not we operating in the context of a project
      def project?
        !@project_root.nil?
      end

      # @return [String,nil] directory in which to find project generators, or +nil+ if not a {project?}
      def project_generator_path
        path_if_for_project generator_path.last
      end

      # @return [String,nil] directory in which to find project templates, or +nil+ if not a {project?}
      def project_template_path
        path_if_for_project template_path.last
      end
      
      # @return [String,nil] directory in which to find project plugins, or +nil+ if not a {project?}
      def project_plugin_path
        path_if_for_project plugin_path.last
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