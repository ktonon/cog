module Cog
  
  # @api developer
  # Methods for querying and manipulating project files
  module Embeds
    
    # Search through all project files for cog embeds, and remember them so that generators can refer to them later
    def gather_from_project
      @embeds ||= {}
      Cog.supported_project_files.each do |filename|
        gather_from_file filename, :hash => @embeds, :type => 'cog'
      end
    end
    
    # @param original [String] file in which to search for keep statements
    # @param scratch [String] file to which keep bodies will be copied (used to create the {EmbedContext} objects)
    # @return [Hash] mapping from hooks to {EmbedContext} objects
    def gather_keeps(original, scratch)
      keeps = {}
      gather_from_file(original, :type => 'keep').each_pair do |hook, count|
        c = keeps[hook] = EmbedContext.new(hook, scratch, count[original])
        raise Errors::DuplicateKeep.new :hook => hook if c.count > 1
        Helpers::FileScanner.scan(original, statement('keep', hook)) do |s|
          c.keep_body = if s.match[4] == '{'
            s.capture_until end_statement('keep')
            s.captured_text
          else
            ''
          end
        end
      end
      keeps
    end
    
    # Copy keep bodies from the original file to the scratch file
    # @param original [String] file in which to search for keep statements. If the original does not exist, then scratch will serve as the original (we do this so that the keeps will get expanded in any case)
    # @param scratch [String] file to which keep bodies will be copied
    # @return [nil]
    def copy_keeps(original, scratch)
      Cog.activate_language(:filename => original) do
        original = scratch unless File.exists? original
        keeps = gather_keeps original, scratch
        keeps.each_pair do |hook, c|
          result = update c, :type => 'keep' do |c|
            c.keep_body
          end
          raise Errors::UnrecognizedKeepHook.new :hook => hook, :filename => original if result.nil?
        end
      end
    end

    # @param filename [String] file from which to gather statements
    # @option opt [Hash] :hash ({}) object in which to gather the mapping
    # @option opt [String] :type ('cog') one of <tt>'cog'</tt> or <tt>'keep'</tt>
    # @return [Hash] mapping from hooks to <tt>{ 'filename' => count }</tt> hashes
    def gather_from_file(filename, opt={})
      bucket = opt[:hash] || {}
      type = opt[:type] || 'cog'
      lang = Cog.language_for filename
      File.read(filename).scan(statement type, '[-A-Za-z0-9_.]+', :lang => lang) do |m|
        hook = m[0]
        bucket[hook] ||= {}
        bucket[hook][filename] ||= 0
        bucket[hook][filename] += 1
      end
      bucket
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
    # @option opt [String] :type ('cog') one of <tt>'cog'</tt> or <tt>'keep'</tt>
    # @yieldparam context [EmbedContext] describes the context in which the embed statement was found
    # @yieldreturn [String] the value to substitute into the embed expansion 
    # @return [Boolean,nil] +true+ if the statement was expanded or updated, +false+ if the statement was found, but not changed, +nil+ if it could not be found.
    def update(c, opt={}, &block)
      type = opt[:type] || 'cog'
      Helpers::FileScanner.scan(c.path, statement(type, c.hook), :occurrence => c.actual_index) do |s|
        c.lineno = s.marked_line_number
        c.args = s.match[2].split if s.match[2]
        c.once = !s.match[3].nil?
        if s.match[4] == '{'
          update_body c, s, opt, &block
        else
          expand_body c, s, opt, &block
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
    def statement(type, hook, opt={})
      lang = opt[:lang] || Cog.active_language
      lang.comment_pattern("#{type}\\s*:\\s*(#{hook})\\s*(?:\\(\\s*(.+?)\\s*\\))?(\\s*once\\s*)?(?:\\s*([{]))?")
    end
    
    # @return [Regexp] pattern to match the end of a cog embed statement
    def end_statement(type = 'cog')
      Cog.active_language.comment_pattern("#{type}\\s*:\\s*[}]")
    end

    # @return [Regexp] pattern to match an line that looks like a cog statement, but is not the end statement
    def anything_but_end(type = 'cog')
      Cog.active_language.comment_pattern("#{type}\\s*:\\s*(?!\\s*[}]).*$")
    end
    
    # @param c [EmbedContext]
    # @param s [FileScanner]
    # @option opt [String] :type ('cog') one of <tt>'cog'</tt> or <tt>'keep'</tt>
    # @return [Boolean] whether or not the scanner updated its file
    def update_body(c, s, opt={}, &block)
      type = opt[:type] || 'cog'
      unless s.capture_until end_statement(type), :but_not => anything_but_end(type)
        raise Errors::SnippetExpansionUnterminated.new :filename => c.path.relative_to_project_root, :line => s.marked_line_number
      end
      c.body = s.captured_text
      value = block.call(c).rstrip
      if c.once? || value.normalize_eol != s.captured_text.rstrip.normalize_eol
        s.replace_captured_text(value + "\n", :once => c.once?)
      else
        false
      end
    end
    
    # @param c [EmbedContext]
    # @param s [FileScanner]
    # @option opt [String] :type ('cog') one of <tt>'cog'</tt> or <tt>'keep'</tt>
    # @return [Boolean] whether or not the scanner updated its file
    def expand_body(c, s, opt={}, &block)
      type = opt[:type] || 'cog'
      lang = Cog.active_language
      value = block.call(c).rstrip
      snip_line = lang.comment "#{c.to_statement type} {"
      unless c.once?
        value = [snip_line, value, lang.comment("#{type}: }")].join("\n")
      end
      s.insert_at_mark(value + "\n")
    end
    
    public
    
    extend self

  end
end
