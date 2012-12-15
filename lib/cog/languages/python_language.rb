require 'cog/languages/language'
require 'cog/languages/mixins/hash_comments'

module Cog
  module Languages
    
    class PythonLanguage < Language
      include Mixins::HashComments

      def module_extensions
        [:py]
      end
      
      def multi_line_comment(text)
        "'''\n#{text}\n'''"
      end

    end
  end
end
