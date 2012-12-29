module Cog

  # Describes a language support by Cog
  class Language

    # @return [Array<String>] list of file extensions
    attr_reader :extensions
      
    # @return [String] unique lower case identifier
    attr_reader :key

    # @return [String] readable name for the language
    attr_reader :name
    
    # @return [String] the style of comments used by this language
    attr_reader :comment_style
      
    # @api developer
    # Initialize with default values
    # @param key [String] unique case-insensitive identifier
    def initialize(key = :text)
      @key = key.to_s.downcase
      @name = key.to_s
      @comment_pattern = '^\s*(%s)\s*$'
      @comment_prefix = nil
      @multiline_comment_prefix = nil
      @multiline_comment_postfix = nil
      @extensions = []
      identibitch = lambda {|name| ''}
      @use_named_scope_block = identibitch
      @named_scope_begin_block = identibitch
      @named_scope_end_block = identibitch
      @include_guard_begin_block = identibitch
      @include_guard_end_block = identibitch
    end
      
    # @param nested_pattern [String] regular expression pattern (as a string) to embed in the regular expression which matches one line comments in this language
    # @return [Regexp] pattern for matching one line comments in this language
    def comment_pattern(nested_pattern)
      Regexp.new(@comment_pattern % nested_pattern)
    end
      
    # @param text [String] some text which should be rendered as a comment
    # @return [String] a comment appropriate for this language
    def comment(text)
      if text =~ /\n/
        multi_line_comment text
      else
        one_line_comment text
      end
    end

    # @api developer
    def one_line_comment(text)
      if @comment_prefix
        "#{@comment_prefix} #{text}"
      elsif @multiline_comment_prefix
        "#{@multiline_comment_prefix} #{text} #{@multiline_comment_postfix}"
      else
        text
      end
    end
      
    # @api developer
    def multi_line_comment(text)
      if @multiline_comment_prefix
        "#{@multiline_comment_prefix}\n#{text}\n#{@multiline_comment_postfix}"
      elsif @comment_prefix
        text.split("\n").collect do |line|
          "#{@comment_prefix} #{line}"
        end.join("\n")
      else
        text
      end
    end
    
    # @api developer
    # Called after all Cogfiles have been processed
    # @option other [Language] map of keys to languages
    def apply_comment_style(other)
      @comment_prefix = other.instance_eval {@comment_prefix}
      @multiline_comment_prefix = other.instance_eval {@multiline_comment_prefix}
      @multiline_comment_postfix = other.instance_eval {@multiline_comment_postfix}
      @comment_pattern = other.instance_eval {@comment_pattern}
    end
    
    # @param w [FixNum] width of the first column
    # @return [String] one line summary in two columns
    def to_s(w=nil)
      w ||= @name.length
      "#{@name.ljust w} -> #{@extensions.collect {|x| x.to_s}.sort.join ', '}"
    end

    # Sort by name
    def <=>(other)
      @name <=> other.name
    end
    
    # @param name [String] name of the scope to use
    # @return [String] a using statement for the named scope
    def use_named_scope(name)
      @use_named_scope_block.call name
    end
      
    # @param name [String] name of the scope
    # @return [String] begin a named scope
    def named_scope_begin(name)
      @named_scope_begin_block.call name
    end

    # @param name [String] name of the scope
    # @return [String] end the given named scope
    def named_scope_end(name)
      @named_scope_end_block.call name
    end
      
    # @param name [String] name of the module to protect
    # @return [String] an include guard statement
    def include_guard_begin(name)
      @include_guard_begin_block.call name
    end
      
    # @param name [String] name of the module to protect
    # @return [String] an include guard end statement
    def include_guard_end(name)
      @include_guard_end_block.call name
    end
  end
end
