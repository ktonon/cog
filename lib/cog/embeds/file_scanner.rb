module Cog
  module Embeds

    # @api developer
    # Helper for scanning files for embed expansions
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
        @marked_line_number = @f.lineno + 1
      end
      
      def unmark!
        @mark = nil
        @marked_line_number = -1
      end
      
      # @return [Fixnum] line number where mark! was called or -1 if mark! was not called
      attr_reader :marked_line_number
      
      # Advances the file until the (n+1)th occurence of the given pattern is encountered, or the end of the file is reached
      # @param pattern [Regexp] a pattern to test for
      # @param n [Fixnum] 0 for the first, 1 for the second, and so on
      # @return [MatchData, nil] the match object if the pattern was found
      def read_until(pattern, n=0)
        i = 0
        mark!
        while (line = @f.readline) && i <= n
          if m = pattern.match(line)
            return m if i == n
            i += 1
          end
          mark!
        end
      rescue EOFError
        unmark!
        nil
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
      # @param opt [Boolean] :once (false) if once, the cog delimiters will be removed
      # @return [Boolean] whether or not the operation succeeded
      def replace_captured_text(value, opt={})
        return false if @cap_begin_pos.nil? || @cap_end_pos.nil?
        @f.seek 0
        tmp.write @f.read(opt[:once] ? @mark : @cap_begin_pos)
        tmp.write value
        @f.seek @cap_end_pos
        @f.readline if opt[:once]
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
        @f.readline # discard original
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
    
  end
end
