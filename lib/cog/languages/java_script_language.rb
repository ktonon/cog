require 'cog/languages/c_language'

module Cog
  module Languages
    
    class JavaScriptLanguage < CLanguage

      # @return [Array<String>] a set of extensions needed to define a module in this language
      def module_extensions
        [:js]
      end
      
      # @param name [String] name of the scope
      # @return [String] begin a named scope
      def named_scope_begin(name)
        "var #{name} = { // named scope"
      end

      # @param name [String] name of the scope
      # @return [String] end the given named scope
      def named_scope_end(name)
        "}; // named scope: #{name}"
      end
      
      # @return [String] ignored for javascript
      def include_guard_begin(name)
        ""
      end
      
      # @return [String] ignored for javascript
      def include_guard_end(name)
        ""
      end

    end
  end
end
