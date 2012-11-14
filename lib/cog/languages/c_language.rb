require 'cog/languages/language'

module Cog
  module Languages
    
    class CLanguage < Language

      def comment(text)
        "/*\n#{text}\n */"
      end

      def module_extensions
        [:c, :h]
      end
    end
  end
end
