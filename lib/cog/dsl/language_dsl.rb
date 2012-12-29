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
      def extension(*values)
        lang_eval do
          @extensions = values.collect {|key| key.to_s.downcase}
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
      
      
      # @api developer
      # Compute the comment pattern
      # @return [Cog::Language] the defined language
      def finalize
        pattern = /[*]/
        esc = lambda do |x|
          x.gsub(pattern) {|match| "\\#{match}"}
        end
        
        lang_eval do
          @comment_style = key unless @comment_style
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
