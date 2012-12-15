require 'cog/config'
require 'cog/embed_context'
require 'cog/embeds/file_scanner'
require 'cog/errors'

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
      lang = Cog.active_language
      s = FileScanner.new c.path
      updated = if match = s.read_until(statement(c.hook), c.actual_index)
        if match.nil? # embed not found
          false
        else
          c.lineno = s.marked_line_number
          c.args = match[2].split if match[2]
          c.once = !match[3].nil?
          if match[4] == '{' # embed already expanded
            unless s.capture_until end_statement, :but_not => anything_else
              raise Errors::SnippetExpansionUnterminated.new "#{c.path.relative_to_project_root}:#{s.marked_line_number}"
            end
            c.body = s.captured_text
            value = block.call(c).rstrip
            if c.once? || value != s.captured_text
              s.replace_captured_text(value + "\n", :once => c.once?)
            end
          else # embed not yet expanded
            value = block.call(c).rstrip
            snip_line = lang.comment "#{c.to_directive} {"
            unless c.once?
              value = [snip_line, value, lang.comment("cog: }")].join("\n")
            end
            s.insert_at_mark(value + "\n")
          end
        end
      end
      s.close
      updated
    end
    
    private
    
    def statement(hook, opt={})
      lang = opt[:lang] || Cog.active_language
      lang.comment_pattern("cog\\s*:\\s*(#{hook})\\s*(?:\\(\\s*(.+?)\\s*\\))?(\\s*once\\s*)?(?:\\s*([{]))?")
    end
    
    def end_statement
      Cog.active_language.comment_pattern("cog\\s*:\\s*[}]")
    end
    
    def anything_else
      Cog.active_language.comment_pattern("cog\\s*:\\s*(?!\\s*[}]).*$")
    end
    
    public
    
    extend self

  end
end
