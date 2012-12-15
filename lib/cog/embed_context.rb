require 'cog/config'

module Cog

  # Describes the environment of an embed statement including the file in which it was found, the line number, the language, an more.
  class EmbedContext
      
    # @return [String] for expanded embed statements, the body of text which occurs between the curly braces
    # @example
    #   // cog: my-hook {
    #   this is
    #   the
    #   body
    #   // cog: }
    attr_reader :body
      
    # @return [String] hook name used in the embed statement
    # @example
    #   // cog: this-is-the-hook-name
    attr_reader :hook

    # @return [Fixnum] line number at which the embed statement was found, with 1 being the first line in the file
    attr_reader :lineno
      
    # @return [Fixnum] if multiple embeds with the same {#hook} occurred more than once in the same file, this value indicates to which occurrence this context belongs. 0 for the first, 1 for the second, and so on...
    attr_reader :index
      
    # @return [Fixnum] if multiple embeds with the same {#hook} occurred more than once in the same file, this value indicates the total number of occurrences
    attr_reader :count
      
    # @return [String] full file system path to the file
    attr_reader :path
      
    # @api developer
    # @param hook [String] hook name used in the embed statement
    # @param path [String] path to the file in which the cog directive was found
    # @param count [Fixnum] total occurrences in file
    def initialize(hook, path, count)
      @hook = hook.to_s
      @path = path.to_s
      @count = count
      @eaten = 0
    end
      
    # @return [Array<String>] arguments provided with the embed statement
    # @example
    #   // cog: my-hook (these are the args)
    def args
      @args
    end
      
    # @return [String] the filename extension (without the period)
    def extension
      @ext ||= File.extname(filename).slice(1..-1)
    end

    # @return [String] basename of the file in which the embed statement was found
    def filename
      @filename ||= File.basename @path
    end
      
    # @return [Boolean] whether or not this was the first occurrence of the embed {#hook} in the file
    def first?
      @index == 0
    end

    # @return [Boolean] whether or not this was the last occurrence of the embed {#hook} in the file
    def last?
      @index == @count - 1
    end
      
    # @return [Boolean] was the 'once' switch used? Embed statements using this switch will be removed after the statement is expanded
    # @example
    #   // cog: my-hook once
    def once?
      @once
    end

    # @api developer
    # @param value [String, nil] set the body to this value
    def body=(value)
      @body = value
    end
      
    # @api developer
    # @param value [Fixnum] set the line number
    def lineno=(value)
      @lineno = value
    end
      
    # @api developer
    # @param value [Boolean] was the once switch used?
    def once=(value)
      @once = !!value
    end
      
    # @api developer
    # @param value [Array<String>] arguments used with the directive
    def args=(value)
      @args = value
    end
      
    # @api developer
    # @param index [Fixnum] occurrence in file, 0 for first
    def index=(index)
      @index = index
    end
      
    # @api developer
    # @param value [Fixnum] the number of once statements before this one that were eaten. Used to adjust the actual_index so that the file_scanner looks for the right statement
    def eaten=(value)
      @eaten = value
    end
      
    # @api developer
    # @return [Fixnum] takes into account the number of once statements that have been eaten
    def actual_index
      @index - @eaten
    end
      
    # @api developer
    # @return [String]
    def to_directive
      x = "cog: #{hook}"
      x += "(#{args.join ' '})" if args
      x += " once" if once?
      x
    end
      
  end
end
