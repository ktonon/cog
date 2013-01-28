module Cog
  module DSL

    # DSL for defining a language
    class LanguageDSL
      
      # @api developer
      # @param key [String] unique case-insensitive identifier
      def initialize(key)
        @lang = Cog::Language.new key
      end

      # Define a readable name for the language
      # @param value [String] readable name of the language
      # @return [nil]
      def name(value)
        lang_eval { @name = value }
        nil
      end
      
      # Define single line comment notation
      # @param prefix [String] starts a single line comment in the language
      # @return [nil]
      def comment(prefix)
        lang_eval { @comment_prefix = prefix }
        nil
      end

      # Define multi-line comment notation
      # @param prefix [String] starts a multi-line comment in the language
      # @param postfix [String] ends a multi-line comment in the language
      # @return [nil]
      def multiline_comment(prefix, postfix)
        lang_eval do
          @multiline_comment_prefix = prefix
          @multiline_comment_postfix = postfix
        end
        nil
      end
      
      # Borrow comment notation from another language
      # @param lang_key [String] use comment notation from the language with the given key
      # @return [nil]
      def comment_style(lang_key)
        lang_eval { @comment_style = lang_key.to_s.downcase }
        nil
      end

      # Define file extensions
      # @param values [Array<String>] list of file extensions for this language
      # @return [nil]
      def extension(*values)
        lang_eval do
          @extensions = values.collect {|key| key.to_s.downcase}
        end  
      end
      
      def seed_extension(ext, opt={})
        lang_eval do
          @seed_extension = ext.to_s.downcase
          @seed_header = opt[:header].to_s.downcase if opt[:header]
        end  
      end
      
      # Define a block to call when using a named scopes in this language
      # @yieldparam name [String] name of the scope to use
      # @yieldreturn [String] a using named scope statement in this language
      # @return [nil]
      def use_named_scope(&block)
        lang_eval { @use_named_scope_block = block }
        nil
      end
      
      # Define a block to call when beginning a named scope in this language
      # @yieldparam name [String] name of the scope to begin
      # @yieldreturn [String] a begin named scope statement in this language
      # @return [nil]
      def named_scope_begin(&block)
        lang_eval { @named_scope_begin_block = block }
        nil
      end

      # Define a block to call when ending a named scope in this language
      # @yieldparam name [String] name of the scope to end
      # @yieldreturn [String] an end named scope statement in this language
      # @return [nil]
      def named_scope_end(&block)
        lang_eval { @named_scope_end_block = block }
        nil
      end
      
      # Define a block to call when beginning an include guard in this language
      # @yieldparam name [String] name of the guard
      # @yieldreturn [String] a begin guard in this language
      # @return [nil]
      def include_guard_begin(&block)
        lang_eval { @include_guard_begin_block = block }
        nil
      end
      
      # Define a block to call when ending an include guard in this language
      # @yieldparam name [String] name of the guard
      # @yieldreturn [String] an end guard in this language
      # @return [nil]
      def include_guard_end(&block)
        lang_eval { @include_guard_end_block = block }
        nil
      end
      
      # Borrow include guard notation from another language
      # @param lang_key [String] use include guard notation from the language with the given key
      # @return [nil]
      def include_guard_style(lang_key)
        lang_eval { @include_guard_style = lang_key.to_s.downcase }
        nil
      end

      # Enumerate reserved identifiers in the language
      # @param words [Array<String>] a list of words which must not be used as identifiers in the language
      # @return [nil]
      def reserved(words)
        lang_eval { @reserved = words }
        nil
      end
      
      # Map a cog primitive type to a native type in this language
      # @param name [Symbol] name of the cog primitive type
      # @param ident [String] identifier of the mapped type in this language
      # @yieldparam obj [Object] a ruby object
      # @yieldreturn [String,nil] the literal representation of the given obj in this language, or +nil+ if the object can not be mapped
      # @return [nil]
      def map_primitive(name, ident, &block)
        lang_eval do
          @prim_ident[name.to_sym] = ident.to_s
          @prim_to_lit[name.to_sym] = block
        end
        nil
      end
      
      # Map the cog boolean type to a native type in this language
      # @param ident [String] identifier of the boolean type in this language
      # @yieldparam obj [Object] a ruby object
      # @yieldreturn [String,nil] the boolean literal representation of the given obj in this language, or +nil+ if the object can not be mapped
      # @return [nil]
      def map_boolean(ident, &block) ; map_primitive(:boolean, ident, &block) ; end

      # Map the cog integer type to a native type in this language
      # @param ident [String] identifier of the integer type in this language
      # @yieldparam obj [Object] a ruby object
      # @yieldreturn [String,nil] the integer literal representation of the given obj in this language, or +nil+ if the object can not be mapped
      # @return [nil]
      def map_integer(ident, &block) ; map_primitive(:integer, ident, &block) ; end
      
      # Map the cog long type to a native type in this language
      # @param ident [String] identifier of the long type in this language
      # @yieldparam obj [Object] a ruby object
      # @yieldreturn [String,nil] the long literal representation of the given obj in this language, or +nil+ if the object can not be mapped
      # @return [nil]
      def map_long(ident, &block) ; map_primitive(:long, ident, &block) ; end
      
      # Map the cog float type to a native type in this language
      # @param ident [String] identifier of the float type in this language
      # @yieldparam obj [Object] a ruby object
      # @yieldreturn [String,nil] the float literal representation of the given obj in this language, or +nil+ if the object can not be mapped
      # @return [nil]
      def map_float(ident, &block) ; map_primitive(:float, ident, &block) ; end
      
      # Map the cog double type to a native type in this language
      # @param ident [String] identifier of the double type in this language
      # @yieldparam obj [Object] a ruby object
      # @yieldreturn [String,nil] the double literal representation of the given obj in this language, or +nil+ if the object can not be mapped
      # @return [nil]
      def map_double(ident, &block) ; map_primitive(:double, ident, &block) ; end
      
      # Map the cog char type to a native type in this language
      # @param ident [String] identifier of the char type in this language
      # @yieldparam obj [Object] a ruby object
      # @yieldreturn [String,nil] the char literal representation of the given obj in this language, or +nil+ if the object can not be mapped
      # @return [nil]
      def map_char(ident, &block) ; map_primitive(:char, ident, &block) ; end
      
      # Map the cog string type to a native type in this language
      # @param ident [String] identifier of the string type in this language
      # @yieldparam obj [Object] a ruby object
      # @yieldreturn [String,nil] the string literal representation of the given obj in this language, or +nil+ if the object can not be mapped
      # @return [nil]
      def map_string(ident, &block) ; map_primitive(:string, ident, &block) ; end
      
      # Map the cog null type to a native type in this language
      # @param ident [String] identifier of the null type in this language
      # @yieldparam obj [Object] a ruby object
      # @yieldreturn [String,nil] the null literal representation of the given obj in this language, or +nil+ if the object can not be mapped
      # @return [nil]
      def map_null(ident, &block) ; map_primitive(:null, ident, &block) ; end
      
      def map_void(ident) ; map_primitive(:void, ident) ; end
      
      # @api developer
      # Compute the comment pattern
      # @return [Cog::Language] the defined language
      def finalize
        pattern = /[*]/
        esc = lambda do |x|
          x.gsub(pattern) {|match| "\\#{match}"}
        end
        
        lang_eval do
          @include_guard_style ||= key
          @comment_style ||= key
          @comment_pattern = if @comment_prefix && @multiline_comment_prefix
            '^\s*(?:%s|%s)\s*%%s\s*(?:%s)?\s*$' % [@comment_prefix, @multiline_comment_prefix, @multiline_comment_postfix].collect(&esc)
          elsif @comment_prefix
            '^\s*%s\s*%%s\s*$' % esc.call(@comment_prefix)
          elsif @multiline_comment_prefix
            '^\s*%s\s*%%s\s*%s\s*$' % [@multiline_comment_prefix, @multiline_comment_postfix].collect(&esc)
          else
            '^\s*%s\s*$'
          end
        end
        @lang
      end
      
      private
      
      def lang_eval(&block)
        @lang.instance_eval &block
      end

    end
  end
end
