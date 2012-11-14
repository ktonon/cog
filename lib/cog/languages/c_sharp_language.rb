require 'cog/languages/c_language'

module Cog
  module Languages
    
    class CSharpLanguage < CLanguage

      def module_extensions
        [:cs]
      end
    end
  end
end
