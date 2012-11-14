require 'cog/languages/c_language'

module Cog
  module Languages
    
    class CSharpLanguage < CLanguage

      # @return [Array<String>] a set of extensions needed to define a module in this language
      def module_extensions
        [:cs]
      end
      
      # @param name [String] name of the scope
      # @return [String] begin a named scope
      def named_scope_begin(name)
        "namespace #{name} {"
      end

      # @param name [String] name of the scope
      # @return [String] end the given named scope
      def named_scope_end(name)
        "} // namespace #{name}"
      end
      
      # @return [String] ignored for c#
      def include_guard_begin(name)
        ""
      end
      
      # @return [String] ignored for c#
      def include_guard_end(name)
        ""
      end

    end
  end
end
