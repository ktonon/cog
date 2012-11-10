require 'cog/config'
require 'cog/errors'
require 'rainbow'

module Cog
  module Controllers
    
    # Manage a project's templates
    module TemplateController

      # List the available templates
      # @option opt [Boolean] :verbose (false) list full template paths
      # @return [Array<String>] a list of templates
      def self.list(opt={})
        # Config.instance.templates_path
      end
      
    end
  end
end
