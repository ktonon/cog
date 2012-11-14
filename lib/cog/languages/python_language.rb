require 'cog/languages/language'

module Cog
  module Languages
    
    class PythonLanguage < Language

      def comment(text)
        "'''\n#{text}\n'''"
      end

      def module_extensions
        [:py]
      end
    end
  end
end
