require 'cog/languages/c_language'

module Cog
  module Languages
    
    class PHPLanguage < CLanguage

      def module_extensions
        [:php]
      end
    end
  end
end
