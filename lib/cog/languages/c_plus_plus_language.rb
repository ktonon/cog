require 'cog/languages/c_language'
require 'cog/languages/mixins/c_style_comments'

module Cog
  module Languages
    
    class CPlusPlusLanguage < Language
      include Mixins::CStyleComments

      def module_extensions
        [:cpp, :hpp]
      end
      
      def use_named_scope(name)
        "using namespace #{name};"
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
