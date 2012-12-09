module Cog
  module Languages

    # Interface that must be supported by all +cog+ language helpers.
    # This base class corresponds to a plain text language.
    class Language

      # @param nested_pattern [String] regular expression pattern (as a string) to embed in the regular expression which matches one line comments in this language
      # @return [Regexp] pattern for matching one line comments in this language
      def comment_pattern(nested_pattern)
        /^\s*#{nested_pattern}\s$/
      end
      
      # @param text [String] some text which should be rendered as a comment
      # @return [String] a comment appropriate for this language
      def comment(text)
        if text =~ /\n/
          multi_line_comment text
        else
          one_line_comment text
        end
      end
      
      # @return [Array<String>] a set of extensions needed to define a module in this language
      def module_extensions
        [:txt]
      end
      
      # @param name [String] name of the scope to use
      # @return [String] a using statement for the named scope
      def use_named_scope(name)
        ""
      end
      
      # @param name [String] name of the scope
      # @return [String] begin a named scope
      def named_scope_begin(name)
        ""
      end

      # @param name [String] name of the scope
      # @return [String] end the given named scope
      def named_scope_end(name)
        ""
      end
      
      # @param name [String] name of the module to protect
      # @return [String] an include guard statement
      def include_guard_begin(name)
        ""
      end
      
      # @param name [String] name of the module to protect
      # @return [String] an include guard end statement
      def include_guard_end(name)
        ""
      end

      protected
      
      def one_line_comment(text)
        text
      end
      
      def multi_line_comment(text)
        text.split("\n").collect do |line|
          one_line_comment line
        end.join "\n"
      end
      
    end
  end
end
