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
        Cog.template_path.each_with_index do |path, i|
          cts.add_templates i.to_s, i.to_s, path
        end
        cts.to_a
      end
      
      # Create a new project template
      # @param name [String] name of the template, relative to the project's templates directory
      # @option opt [Boolean] :force_override (false) if a built-in or tool template with the same name already exists, should a project override be created?
      # @return [nil]
      def self.create(name, opt={})
        raise Errors::ActionRequiresProject.new('create template') unless Cog.project?
        name = name.without_extension :erb
        dest = File.join Cog.template_path.last, "#{name}.erb"

        original = Generator.get_template name, :as_path => true
        return if original == dest # Nothing to create
        if opt[:force_override]
          Generator.copy_file_if_missing original, dest
        else
          raise Errors::DuplicateTemplate.new original
        end
        nil
      rescue Errors::NoSuchTemplate
        # No original, ok to create an empty template
        touch_file dest
        nil
      end
      
    end
  end
end
