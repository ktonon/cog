require 'cog/languages/c_language'
require 'cog/languages/mixins/c_style_comments'

module Cog
  module Languages
    
    class JavaScriptLanguage < Language
      include Mixins::CStyleComments

      def module_extensions
        [:js]
      end
      
      def named_scope_begin(name)
        "var #{name} = { // named scope"
      end

      def named_scope_end(name)
        "}; // named scope: #{name}"
      end

    end
  end
end
