require 'cog/mixins/uses_templates'
require 'cog/cogfile'

module Cog
  
  class TemplateController
    
    include Mixins::UsesTemplates
    
    def initialize(opt={})
      using_cogfile Cogfile.master
    end
    
  end
  
end
