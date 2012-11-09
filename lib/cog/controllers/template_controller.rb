require 'cog/config'
require 'cog/generator'
require 'rainbow'

module Cog
  module Controllers
    
    # Manage a project's templates
    module TemplateController

      # List the available templates
      # @option opt [String] :tool (nil) if provided, templates from the given
      #   tool will also be listed
      # @option opt [Boolean] :verbose (false) list full template paths
      # @return [Array<String>] a list of templates
      def self.list(opt={})
        # TODO
      end
      
    end
  end
end
