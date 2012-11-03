module Cog
  
  module Errors
    # Indiciates an attempt to use a non-existant template.
    class MissingTemplate < Exception
      def initialize(template_path)
        @template_path = template_path
      end
      
      def message
        "could not find the template '#{@template_path}'\n#{super}"
      end
    end
  end

end
