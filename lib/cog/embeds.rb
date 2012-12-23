module Cog
  
  # @api developer
  # Methods for querying and manipulating project files
  module Embeds
    
    # Search through all project files for cog embeds, and remember them so that generators can refer to them later
    def gather_from_project
      @embeds ||= {}
      Cog.supported_project_files.each do |filename|
        lang = Cog.language_for filename
        File.read(filename).scan(statement '[-A-Za-z0-9_.]+', :lang => lang) do |m|
          hook = m[0]
          @embeds[hook] ||= {}
          @embeds[hook][filename] ||= 0
          @embeds[hook][filename] += 1
        end
      end
    end
    
    # @param hook [String] embed hook for which to find directive occurrences
    # @yieldparam context [EmbedContext] describes the context in which the embed statement was found
    def find(hook)
      x = @embeds[hook]
      unless x.nil?
        x.keys.sort.each do |filename|
          c = EmbedContext.new hook, filename, x[filename]
          Cog.activate_language :ext => c.extension do
            c.count.times do |index|
              c.index = index
              yield c
            end
          end
        end
      end
    end
    
    # @param c [EmbedContext] describes the context in which the embed statement was found
    # @yieldparam context [EmbedContext] describes the context in which the embed statement was found
    # @yieldreturn [String] the value to substitute into the embed expansion 
    # @return [Hash] whether or not the expansion was updated
    def update(c, &block)
      Helpers::FileScanner.scan(c.path, statement(c.hook), :occurrence => c.actual_index) do |s|
        c.lineno = s.marked_line_number
        c.args = s.match[2].split if s.match[2]
        c.once = !s.match[3].nil?
        if s.match[4] == '{'
          update_body c, s, &block
        else
          expand_body c, s, &block
        end
      end
    end
    
    private
    
    # Pattern groups are
    # * 1 - hook
    # * 2 - args
    # * 3 - once
    # * 4 - expansion begin (curly <tt>{</tt>)
    # @return [Regexp] pattern to match the beginning of a cog embed statement
    def statement(hook, opt={})
      lang = opt[:lang] || Cog.active_language
      lang.comment_pattern("cog\\s*:\\s*(#{hook})\\s*(?:\\(\\s*(.+?)\\s*\\))?(\\s*once\\s*)?(?:\\s*([{]))?")
    end
    
    # @return [Regexp] pattern to match the end of a cog embed statement
    def end_statement
      Cog.active_language.comment_pattern("cog\\s*:\\s*[}]")
    end

    # @return [Regexp] pattern to match an line that looks like a cog statement, but is not the end statement
    def anything_but_end
      Cog.active_language.comment_pattern("cog\\s*:\\s*(?!\\s*[}]).*$")
    end
    
    # @param c [EmbedContext]
    # @param s [FileScanner]
    # @return [Boolean] whether or not the scanner updated its file
    def update_body(c, s, &block)
      unless s.capture_until end_statement, :but_not => anything_but_end
        raise Errors::SnippetExpansionUnterminated.new "#{c.path.relative_to_project_root}:#{s.marked_line_number}"
      end
      c.body = s.captured_text
      value = block.call(c).rstrip
      if c.once? || value != s.captured_text
        s.replace_captured_text(value + "\n", :once => c.once?)
      end
    end
    
    # @param c [EmbedContext]
    # @param s [FileScanner]
    # @return [Boolean] whether or not the scanner updated its file
    def expand_body(c, s, &block)
      lang = Cog.active_language
      value = block.call(c).rstrip
      snip_line = lang.comment "#{c.to_directive} {"
      unless c.once?
        value = [snip_line, value, lang.comment("cog: }")].join("\n")
      end
      s.insert_at_mark(value + "\n")
    end
    
    public
    
    extend self

  end
end
