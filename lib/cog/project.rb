require 'cog/config'

module Cog
  
  # Methods for querying and manipulating project files
  module Project

    # Search through all project files for cog directives, and remember them so that generators can refer to them later
    def gather_cog_directives
      @snippets ||= {}
      @snippet_pattern ||= "cog:\\s*snippet\\s*\\(\\s*(.*?)\\s*\\)"
      exts = Config.instance.language_summary.collect(&:extensions).flatten
      sources = Dir.glob "#{Config.instance.project_source_path}/**/*.{#{exts.join ','}}"
      sources.each do |filename|
        ext = File.extname(filename).slice(1..-1)
        lang = Config.instance.language_for_extension ext
        w = File.read filename
        w.scan(lang.comment_pattern(@snippet_pattern)) do |m|
          key = m[0]
          @snippets[key] ||= {}
          @snippets[key][filename] ||= 0
          @snippets[key][filename] += 1
        end
      end
    end
    
    # @param key [String] snippet key for which to find directive occurrences
    # @yieldparam filename [String] name of the file in which the snippet occurred
    # @yieldparam index [Fixnum] occurrence index of the snippet, 0 for the first occurrence, 1 for the second, and so on
    def snippet_directives(key)
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
    # @param value [String] expansion value to use as the update
    # @return [Boolean] whether or not the expansion was updated
    def update_snippet_expansion(key, filename, index, value)
      value = value.rstrip
      ext = File.extname(filename).slice(1..-1)
      lang = Config.instance.language_for_extension ext
      
      snip_pattern = lang.comment_pattern("cog:\\s*snippet\\s*\\(\\s*#{key}\\s*\\)")
      begin_pattern = lang.comment_pattern("cog:\\s*begin")
      end_pattern = lang.comment_pattern("cog:\\s*end")
      not_end_pattern = lang.comment_pattern("cog:\\s*(?!\\s*end).*$")
      
      s = FileScanner.new filename
      updated = if s.read_until snip_pattern, index
        s.mark!
        if s.readline_matches? begin_pattern
          unless s.capture_until end_pattern, :but_not => not_end_pattern
            raise Errors::SnippetExpansionUnterminated.new "#{filename.relative_to_project_root}:#{s.marked_line_number}"
          end
          s.replace_captured_text(value + "\n") if value != s.captured_text
        else # 'cog: begin' not found
          value = [lang.comment("cog: begin"), value, lang.comment("cog: end") + "\n"]
          s.insert_at_mark value.join("\n")
        end
      end
      s.close
      updated
    end
    
    # Helper for scanning files for snippet expansions
    class FileScanner

      def initialize(filename)
        @filename = filename
        @f = File.open filename, 'r'
        @lines = []
        @mark = nil
        @cap_begin_pos = nil
        @cap_end_pos = nil
      end

      # Closes the scanned file, if it is not already closed
      def close
        @f.close unless @f.closed?
      end
      
      # Remember this position. A later call to insert_at_mark will insert at this marked position
      # @return [nil]
      def mark!
        @mark = @f.pos
        @marked_line_number = @f.lineno
      end
      
      # @return [Fixnum] line number where mark! was called or -1 if mark! was not called
      attr_reader :marked_line_number
      
      # Advances the file until the (n+1)th occurence of the given pattern is encountered, or the end of the file is reached
      # @param pattern [Regexp] a pattern to test for
      # @param n [Fixnum] 0 for the first, 1 for the second, and so on
      # @return [Boolean] whether or not the pattern was found
      def read_until(pattern, n=0)
        i = 0
        while (line = @f.readline) && i <= n
          if line =~ pattern
            return true if i == n
            i += 1
          end
        end
      rescue EOFError
        false
      end
      
      # Advances the file by one line
      # @param pattern [Regexp] a pattern to test for
      # @return [Boolean] whether or not the next line matched the pattern
      def readline_matches?(pattern)
        !!(@f.readline =~ pattern)
      rescue EOFError
        false
      end
      
      # Advances the file until the given pattern is encountered and captures lines as it reads. The line which matches the pattern will not be captured. Captured lines can later be recovered with captured_text
      # @param pattern [Regexp] a pattern to test for
      # @option opt [Array<Regexp>, Regexp] :but_not (nil) if a line matching any of the provided patterns is found before the desired pattern :bad_pattern_found will be thrown
      # @return [Boolean] whether or not the pattern was found
      def capture_until(pattern, opt={})
        @cap_begin_pos = @f.pos
        but_not = opt[:but_not] || []
        but_not = [but_not] unless but_not.is_a?(Array)
        while line = @f.readline
          but_not.each do |bad_pattern|
            if bad_pattern =~ line
              return false
            end
          end
          return true if line =~ pattern
          @lines << line
          @cap_end_pos = @f.pos
        end
      rescue EOFError
        false
      end
      
      # @return [String] text captured during capture_until. The last newline is stripped
      def captured_text
        x = @lines.join('')
        x = x.slice(0..-2) if x =~ /\n$/
        x
      end
      
      # @param value [String] value to replace the captured_text with
      # @return [Boolean] whether or not the operation succeeded
      def replace_captured_text(value)
        return false if @cap_begin_pos.nil? || @cap_end_pos.nil?
        @f.seek 0
        tmp.write @f.read(@cap_begin_pos)
        tmp.write value
        @f.seek @cap_end_pos
        tmp.write @f.read
        tmp.close
        close
        FileUtils.mv tmp_filename, @filename
        true
      end
      
      # @param value [String] value to be inserted into the file at the current position
      # @return [Boolean] whether or not the operation succeeded
      def insert_at_mark(value)
        return false if @mark.nil?
        @f.seek 0
        tmp.write @f.read(@mark)
        tmp.write value
        tmp.write @f.read
        tmp.close
        close
        FileUtils.mv tmp_filename, @filename
        true
      end
      
      private
      
      def tmp_filename
        @tmp_filename ||= "#{@filename}.tmp"
      end
      
      def tmp
        @tmp ||= File.open(tmp_filename, 'w')
      end
    end
    
    extend self # Singleton
  end
  
end
