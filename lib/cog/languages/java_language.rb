require 'cog/languages/c_language'

module Cog
  module Languages
    
    class JavaLanguage < CLanguage

      # @return [Array<String>] a set of extensions needed to define a module in this language
      def module_extensions
        [:java]
      end
      
      # @param name [String] name of the scope
      # @return [String] begin a named scope
      def named_scope_begin(name)
        "package #{name};"
      end

      # @param name [String] name of the scope
      # @return [String] end the given named scope
      def named_scope_end(name)
        "// end of package: #{name}"
      end
      
      # @return [String] ignored for java
      def include_guard_begin(name)
        ""
      end
      
      # @return [String] ignored for java
      def include_guard_end(name)
        ""
      end

    end
  end
end
