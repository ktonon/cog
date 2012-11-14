require 'cog/languages/language'

module Cog
  module Languages
    
    class RubyLanguage < Language

      def comment(text)
        "=begin\n#{text}\n=end"
      end

      def module_extensions
        [:rb]
      end
    end
  end
end
