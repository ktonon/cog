module Cog
  module Controllers
    
    # Manage a project's templates
    module TemplateController

      # Create a new project template
      # @param name [String] name of the template, relative to the project's templates directory
      # @option opt [Boolean] :force_override (false) if a built-in or plugin template with the same name already exists, should a project override be created?
      # @return [nil]
      def self.create(name, opt={})
        raise Errors::ActionRequiresProject.new('create template') unless Cog.project?
        name = name.without_extension :erb
        dest = File.join Cog.project_template_path, "#{name}.erb"
        original = Generator.get_template name, :as_path => true
        Generator.copy_file_if_missing original, dest
        nil
      rescue Errors::NoSuchTemplate
        # No original, ok to create an empty template
        Generator.touch_file dest
        nil
      end

      # List the available templates
      # @return [Array<String>] a list of templates
      def self.list
        Helpers::CascadingSet.process_paths Cog.template_path, :ext => 'erb'
      end
      
    end
  end
end
