require 'cog/languages/c_language'
require 'cog/languages/mixins/c_style_comments'

module Cog
  module Languages
    
    class CSharpLanguage < Language
      include Mixins::CStyleComments

      def module_extensions
        [:cs]
      end
      
      def named_scope_begin(name)
        "namespace #{name} {"
      end

      def named_scope_end(name)
        "} // namespace #{name}"
      end
      
    end
  end
end
