require 'cog/languages/language'

module Cog
  module Languages
    
    class PythonLanguage < Language

      # @param text [String] some text which should be rendered as a comment
      # @return [String] a comment appropriate for this language
      def comment(text)
        "'''\n#{text}\n'''"
      end
      
      # @return [Array<String>] a set of extensions needed to define a module in this language
      def module_extensions
        [:py]
      end
      
      # @return [String] ignored for python
      def named_scope_begin(name)
        ""
      end

      # @return [String] ignored for python
      def named_scope_end(name)
        ""
      end
      
      # @return [String] ignored for python
      def include_guard_begin(name)
        ""
      end
      
      # @return [String] ignored for python
      def include_guard_end(name)
        ""
      end

    end
  end
end
