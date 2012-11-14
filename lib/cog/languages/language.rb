module Cog
  module Languages

    # Interface that must be supported by all +cog+ language helpers.
    # This base class corresponds to a plain text language.
    class Language
      
      # @param text [String] some text which should be rendered as a comment
      # @return [String] a comment appropriate for this language
      def comment(text)
        text
      end
      
      # @return a set of extensions needed to define a module in this language
      def module_extensions
        [:txt]
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

    end
  end
end
