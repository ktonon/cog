require 'cog/languages/language'

module Cog
  module Languages
    
    class QtProjectLanguage < Language

      # @param nested_pattern [String] regular expression pattern (as a string) to embed in the regular expression which matches one line comments in this language
      # @return [Regexp] pattern for matching one line comments in this language
      def comment_pattern(nested_pattern)
        /^\s*\#\s*#{nested_pattern}\s*$/i
      end

      # @return [Array<String>] a set of extensions needed to define a module in this language
      def module_extensions
        [:pro]
      end
      
      # @return [String] ignored for Qt Project files
      def named_scope_begin(name)
        ""
      end

      # @return [String] ignored for Qt Project files
      def named_scope_end(name)
        ""
      end
      
      # @return [String] ignored for Qt Project files
      def include_guard_begin(name)
        ""
      end
      
      # @return [String] ignored for Qt Project files
      def include_guard_end(name)
        ""
      end

      protected
      
      def one_line_comment(text)
        "# #{text}"
      end
      
    end
  end
end
