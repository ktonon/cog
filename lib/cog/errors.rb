module Cog
  
  module Errors
    
    # Root type for all cog errors
    class CogError < Exception
    end
    
    # Indiciates an attempt to use a non-existant template.
    class MissingTemplate < CogError
      def initialize(template_path)
        @template_path = template_path
      end
      
      def message
        "could not find the template '#{@template_path}'\n#{super}"
      end
    end
    
    # The action requires {Config#project?}
    class ActionRequiresProject < CogError
      def initialize(action)
        @action = action
      end
      
      def message
        "the action '#{@action}' requires a project, but no Cogfile was found"
      end
    end
  end

end
