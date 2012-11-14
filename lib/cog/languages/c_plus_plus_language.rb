require 'cog/languages/c_language'

module Cog
  module Languages
    
    class CPlusPlusLanguage < CLanguage

      def module_extensions
        [:cpp, :hpp]
      end

      def named_scope_begin(name)
        "namespace #{name} {"
      end

      def named_scope_end(name)
        "} // namespace #{name}"
      end

      def include_guard_begin(name)
        "#ifndef #{name}\n#define #{name}"
      end

      def include_guard_end(name)
        "#end // #{name}"
      end
      
    end
  end
end
