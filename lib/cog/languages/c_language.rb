require 'cog/languages/language'

module Cog
  module Languages
    
    class CLanguage < Language

      # @param text [String] some text which should be rendered as a comment
      # @return [String] a comment appropriate for this language
      def comment(text)
        "/*\n#{text}\n */"
      end
      
      # @return [Array<String>] a set of extensions needed to define a module in this language
      def module_extensions
        [:c, :h]
      end
      
      # @return [String] ignored in c
      def named_scope_begin(name)
        ""
      end

      # @return [String] ignored in c
      def named_scope_end(name)
        ""
      end
      
      # @param name [String] name of the module to protect
      # @return [String] an include guard statement
      def include_guard_begin(name)
        "#ifndef #{name}\n#define #{name}"
      end
      
      # @param name [String] name of the module to protect
      # @return [String] an include guard end statement
      def include_guard_end(name)
        "#endif // #{name}"
      end

    end
  end
end
