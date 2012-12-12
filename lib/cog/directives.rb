require 'cog/config'
require 'cog/directives/context'
require 'cog/directives/file_scanner'

module Cog
  
  # Methods for querying and manipulating project files
  module Directives

    # Search through all project files for cog directives, and remember them so that generators can refer to them later
    def gather_from_project
      @snippets ||= {}
      @snippet_pattern ||= "cog\\s*:\\s*snippet\\s*\\(\\s*(.+?)\\s*\\)(\\s*once\\s*)?(\\s*\\{)?"
      exts = Config.instance.language_summary.collect(&:extensions).flatten
      sources = Dir.glob "#{Config.instance.project_source_path}/**/*.{#{exts.join ','}}"
      sources.each do |filename|
        ext = File.extname(filename).slice(1..-1)
        lang = Config.instance.language_for_extension ext
        w = File.read filename
        w.scan(lang.comment_pattern(@snippet_pattern)) do |m|
          key = m[0].split.first
          @snippets[key] ||= {}
          @snippets[key][filename] ||= 0
          @snippets[key][filename] += 1
        end
      end
    end
    
    # @param key [String] snippet key for which to find directive occurrences
    # @yieldparam filename [String] name of the file in which the snippet occurred
    # @yieldparam index [Fixnum] occurrence index of the snippet, 0 for the first occurrence, 1 for the second, and so on
    def snippets_for(key)
      x = @snippets[key]
      unless x.nil?
        x.keys.sort.each do |filename|
          x[filename].times do |index|
            yield filename, index
          end
        end
      end
    end
    
    # @param key [String] unique identifier for the snippet
    # @param filename [String] file in which to look for the snippet
    # @param index [Fixnum] occurrence of the snippet. 0 for first, 1 for second, ...
    # @yieldparam context [Context] describes the context in which the directive occurred
    # @yieldreturn [String] the value to substitute into the snippet expansion 
    # @return [Boolean] whether or not the expansion was updated
    def update_snippet_expansion(key, filename, index, &block)
      c = Context.new filename
      snip_pattern = c.language.comment_pattern("cog\\s*:\\s*snippet\\s*\\(\\s*(#{key})(.*?)\\s*\\)(\\s*once\\s*)?(?:\\s*([{]))?")
      end_pattern = c.language.comment_pattern("cog\\s*:\\s*[}]")
      not_end_pattern = c.language.comment_pattern("cog\\s*:\\s*(?!\\s*[}]).*$")
      
      s = FileScanner.new filename
      updated = if match = s.read_until(snip_pattern, index)
        if match.nil? # snippet not found
          false
        else
          c.lineno = s.marked_line_number
          c.args = match[2].split
          c.once = !match[3].nil?
          if match[4] == '{' # snippet already expanded
            unless s.capture_until end_pattern, :but_not => not_end_pattern
              raise Errors::SnippetExpansionUnterminated.new "#{filename.relative_to_project_root}:#{s.marked_line_number}"
            end
            c.body = s.captured_text
            value = block.call(c).rstrip
            if c.once? || value != s.captured_text
              s.replace_captured_text(value + "\n", :once => c.once?)
            end
          else # snippet not yet expanded
            value = block.call(c).rstrip
            snip_line = c.language.comment "cog: snippet(#{match[1]}) {"
            unless c.once?
              value = [snip_line, value, c.language.comment("cog: }")].join("\n")
            end
            s.insert_at_mark(value + "\n")
          end
        end
      end
      s.close
      updated
    end
    
    extend self # Singleton

  end
end
