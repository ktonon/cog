require 'cog/languages/c_language'

module Cog
  module Languages
    
    class JavaScriptLanguage < CLanguage

      def module_extensions
        [:js]
      end
    end
  end
end
