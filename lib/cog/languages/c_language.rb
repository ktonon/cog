require 'cog/languages/language'
require 'cog/languages/mixins/c_style_comments'

module Cog
  module Languages
    
    class CLanguage < Language
      include Mixins::CStyleComments

      # @return [Array<String>] a set of extensions needed to define a module in this language
      def module_extensions
        [:c, :h]
      end
            
      # @param name [String] name of the module to protect
      # @return [String] an include guard statement
      def include_guard_begin(name)
        "#ifndef #{name}\n#define #{name}"
      end
      
      # @param name [String] name of the module to protect
      # @return [String] an include guard end statement
      def include_guard_end(name)
        "#endif // #{name}"
      end

    end
  end
end
