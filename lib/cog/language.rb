module Cog

  # Describes a language support by Cog
  class Language

    # @return [Array<String>] list of file extensions
    attr_reader :extensions

    attr_reader :seed_extension
    attr_reader :seed_header
    
    # @return [String] unique lower case identifier
    attr_reader :key

    # @return [String] readable name for the language
    attr_reader :name
    
    # @return [String] the style of comments used by this language
    attr_reader :comment_style
    
    # @return [String] the style of include guards used by this language
    attr_reader :include_guard_style
      
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
      @reserved = []
      @prim_ident = {} # :name => 'ident'
      @prim_to_lit = {} # :name => to_literal_block
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
    # @param other [Language] language to borrow notation from
    def apply_comment_style(other)
      @comment_prefix = other.instance_eval {@comment_prefix}
      @multiline_comment_prefix = other.instance_eval {@multiline_comment_prefix}
      @multiline_comment_postfix = other.instance_eval {@multiline_comment_postfix}
      @comment_pattern = other.instance_eval {@comment_pattern}
    end
    
    # @api developer
    # Called after all Cogfiles have been processed
    # @param other [Language] language to borrow notation from
    def apply_include_guard_style(other)
      @include_guard_begin_block = other.instance_eval {@include_guard_begin_block}
      @include_guard_end_block = other.instance_eval {@include_guard_end_block}
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
    
    # @param name [String] a potential identifier name
    # @return [String] an escaped version of the identifier, if it conflicted with a reserved word in the language
    def to_ident(name)
      if @reserved.member? name.to_s
        "#{name}_"
      else
        name.to_s
      end
    end
    
    # @param name [Symbol] name of a primitive cog type
    # @return [String] the representation of a primitive cog type in the native language
    # @example
    #   # For Objective-C
    #   lang.to_prim :boolean # => 'BOOL'
    def to_prim(name)
      ident = @prim_ident[name.to_sym]
      raise Errors::PrimitiveNotSupported.new :type => name, :language => @name unless ident
      ident
    end

    # @param obj [Object] a ruby object
    # @return [String] boolean literal representation of the object in this language
    def to_boolean(obj) ; try_to_lit(:boolean, obj) ; end

    # @param obj [Object] a ruby object
    # @return [String] integer literal representation of the object in this language
    def to_integer(obj) ; try_to_lit(:integer, obj) ; end

    # @param obj [Object] a ruby object
    # @return [String] long literal representation of the object in this language
    def to_long(obj) ; try_to_lit(:long, obj) ; end

    # @param obj [Object] a ruby object
    # @return [String] float literal representation of the object in this language
    def to_float(obj) ; try_to_lit(:float, obj) ; end

    # @param obj [Object] a ruby object
    # @return [String] double literal representation of the object in this language
    def to_double(obj) ; try_to_lit(:double, obj) ; end

    # @param obj [Object] a ruby object
    # @return [String] char literal representation of the object in this language
    def to_char(obj) ; try_to_lit(:char, obj) ; end

    # @param obj [Object] a ruby object
    # @return [String] string literal representation of the object in this language
    def to_string(obj) ; try_to_lit(:string, obj) ; end

    # @param obj [Object] a ruby object
    # @return [String] null literal representation of the object in this language
    def to_null(obj) ; try_to_lit(:null, obj) ; end

    # @param obj [Object] a ruby object
    # @return [String] literal representation of the object in this language
    def to_lit(obj)
      return obj.to_lit if obj.respond_to?(:to_lit)
      raise Errors::PrimitiveNotSupported.new :object => obj
    end

    # @param name [Symbol] name of a primitive cog type
    # @return [String] default value literal for the given primitive cog type
    # @example
    #   # For C++
    #   lang.to_default_value :string # => '""'
    def default_lit_for(name)
      case name
      when :boolean
        to_boolean false
      when :integer
        to_integer 0
      when :long
        to_long 0
      when :float
        to_lit 0.0
      when :double
        to_double 0.0
      when :char
        to_char ''
      when :string
        to_string ''
      when :null
        to_null nil
      end
    end
    
    private    
    
    # @api developer
    def try_to_lit(name, obj)
      to_lit_block = @prim_to_lit[name]
      raise Errors::PrimitiveNotSupported.new :type => name, :language => @name unless to_lit_block
      to_lit_block.call obj if to_lit_block
    end
    
  end
end
