module Cog
  module DSL

    # DSL for defining a language
    class LanguageDSL
      
      # @api developer
      # @param key [String] unique case-insensitive identifier
      def initialize(key)
        @lang = Cog::Language.new key
      end

      def name(value)
        @lang.instance_eval { @name = value }
      end
        
      def comment(prefix)
        @lang.instance_eval do
          @comment_prefix = prefix
        end
      end
        
      def multiline_comment(prefix, postfix)
        @lang.instance_eval do
          @multiline_comment_prefix = prefix
          @multiline_comment_postfix = postfix
        end
      end
        
      def comment_style(lang_key)
        @lang.instance_eval do
          @comment_style = lang_key.to_s.downcase
        end
      end
        
      def extension(*values)
        @lang.instance_eval do
          @extensions = values.collect {|key| key.to_s.downcase}
        end  
      end
      
      # @api developer
      # Compute the comment pattern
      # @return [Cog::Language] the defined language
      def finalize
        pattern = /[*]/
        esc = lambda do |x|
          x.gsub(pattern) {|match| "\\#{match}"}
        end
        
        @lang.instance_eval do
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
      
      
    end
  end
end
