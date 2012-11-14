require 'cog/languages/c_language'

module Cog
  module Languages
    
    class CPlusPlusLanguage < CLanguage

      # @return [Array<String>] a set of extensions needed to define a module in this language
      def module_extensions
        [:cpp, :hpp]
      end
      
      # @param name [String] name of the scope to use
      # @return [String] a using statement for the named scope
      def use_named_scope(name)
        "using namespace #{name};"
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

    end
  end
end
