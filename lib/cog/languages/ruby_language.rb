require 'cog/languages/language'

module Cog
  module Languages
    
    class RubyLanguage < Language

      # @param nested_pattern [String] regular expression pattern (as a string) to embed in the regular expression which matches one line comments in this language
      # @return [Regexp] pattern for matching one line comments in this language
      def comment_pattern(nested_pattern)
        /^\s*\#\s*#{nested_pattern}\s*$/i
      end

      # @return [Array<String>] a set of extensions needed to define a module in this language
      def module_extensions
        [:rb]
      end
      
      # @param name [String] name of the scope
      # @return [String] begin a named scope
      def named_scope_begin(name)
        "module #{name}"
      end

      # @param name [String] name of the scope
      # @return [String] end the given named scope
      def named_scope_end(name)
        "end # module #{name}"
      end
      
      # @return [String] ignored for ruby
      def include_guard_begin(name)
        ""
      end
      
      # @return [String] ignored for ruby
      def include_guard_end(name)
        ""
      end

      protected
      
      def one_line_comment(text)
        "# #{text}"
      end
      
      def multi_line_comment(text)
        "=begin\n#{text}\n=end"
      end

    end
  end
end
