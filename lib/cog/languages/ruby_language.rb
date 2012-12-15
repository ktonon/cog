require 'cog/languages/language'
require 'cog/languages/mixins/hash_comments'

module Cog
  module Languages
    
    class RubyLanguage < Language
      include Mixins::HashComments

      def module_extensions
        [:rb]
      end
      
      def multi_line_comment(text)
        "=begin\n#{text}\n=end"
      end

      def named_scope_begin(name)
        "module #{name}"
      end

      def named_scope_end(name)
        "end # module #{name}"
      end
      
    end
  end
end
