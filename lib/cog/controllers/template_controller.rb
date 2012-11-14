require 'cog/config'
require 'cog/errors'
require 'cog/generator'
require 'cog/helpers'
require 'rainbow'

module Cog
  module Controllers
    
    # Manage a project's templates
    module TemplateController

      # List the available templates
      # @option opt [Boolean] :verbose (false) list full template paths
      # @return [Array<String>] a list of templates
      def self.list(opt={})
        cts = Helpers::CascadingTemplateSet.new
        cts.add_templates 'built-in', :built_in, Config.cog_templates_path, opt
        tool = Config.instance.active_tool
        unless tool.templates_path.nil?
          cts.add_templates tool.name, :tool, tool.templates_path, opt
        end
        if Config.instance.project?
          cts.add_templates 'project', :project, Config.instance.project_templates_path, opt
        end
        cts.to_a
      end
      
      # Create a new project template
      # @param name [String] name of the template, relative to the project's templates directory
      # @option opt [Boolean] :force_override (false) if a built-in or tool template with the same name already exists, should a project override be created?
      # @return [nil]
      def self.create(name, opt={})
        raise Errors::ActionRequiresProject.new('create template') unless Config.instance.project?
        name = name.without_extension :erb
        dest = File.join Config.instance.project_templates_path, "#{name}.erb"
        Object.instance_eval do
          extend Generator
          begin
            original = get_template name, :as_path => true
            return if original == dest # Nothing to create
            if opt[:force_override]
              copy_file_if_missing original, dest
            else
              raise Errors::DuplicateTemplate.new original
            end
          rescue Errors::NoSuchTemplate
            # No original, ok to create an empty template
            touch_file dest
          end
          nil
        end
      end
      
    end
  end
end
