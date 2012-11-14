require 'cog/languages/language'

module Cog
  module Languages
    
    class RubyLanguage < Language

      # @param text [String] some text which should be rendered as a comment
      # @return [String] a comment appropriate for this language
      def comment(text)
        "=begin\n#{text}\n=end"
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

    end
  end
end
