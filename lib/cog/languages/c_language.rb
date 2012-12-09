require 'cog/languages/language'

module Cog
  module Languages
    
    class CLanguage < Language

      # @param nested_pattern [String] regular expression pattern (as a string) to embed in the regular expression which matches one line comments in this language
      # @return [Regexp] pattern for matching one line comments in this language
      def comment_pattern(nested_pattern)
        /^\s*(?:\/\/|\/\*)\s*#{nested_pattern}\s*(?:\*\/)?\s*$/i
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

      protected
      
      def one_line_comment(text)
        "// #{text}"
      end
      
      def multi_line_comment(text)
        "/*\n#{text}\n */"
      end

    end
  end
end
