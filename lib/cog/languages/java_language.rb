require 'cog/languages/c_language'

module Cog
  module Languages
    
    class JavaLanguage < CLanguage

      def module_extensions
        [:java]
      end
    end
  end
end
