require 'cog/languages/c_language'
require 'cog/languages/mixins/c_style_comments'

module Cog
  module Languages
    
    class JavaLanguage < Language
      include Mixins::CStyleComments

      def module_extensions
        [:java]
      end
      
      def named_scope_begin(name)
        "package #{name};"
      end

      def named_scope_end(name)
        "// end of package: #{name}"
      end
      
    end
  end
end
