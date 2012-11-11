require 'cog/config'
require 'cog/errors'
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
        Config.instance.tools.each do |tool|
          unless tool.templates_path.nil?
            cts.add_templates tool.name, :tool, tool.templates_path, opt
          end
        end
        if Config.instance.project?
          cts.add_templates 'project', :project, Config.instance.project_templates_path, opt
        end
        cts.to_a
      end
      
    end
  end
end
