class String
  def normalize_eol
    gsub(/\r\n/, "\n").gsub(/\r/, "\n")
  end
end

module Cog
  module Helpers

    # @api developer
    # Helper for scanning files for embed expansions
    class FileScanner

      # @return [MatchData, nil] match data for the last matched pattern
      attr_reader :match
      
      # @api developer
      def initialize(filename)
        @filename = filename
        @f = File.open filename, 'r'
        @f = @f.binmode if @f.respond_to?(:binmode)
        @lines = []
        @mark = nil
        @cap_begin_pos = nil
        @cap_end_pos = nil
        @cap_end_lineno = nil
        @match = nil # The last match object
        @win_fudge = if RUBY_PLATFORM =~ /(mswin|mingw)/
          x = @f.readline.end_with? "\r\n"
          @f.seek 0
          @f.lineno = 0
          x ? 0 : 1
        else
          0
        end
      end
      
      # @api developer
      # Closes the scanned file, if it is not already closed
      def close
        @f.close unless @f.closed?
      end
      
      # Opens the given file for scanning.
      # @param filename [String] path to the file which will be scanned
      # @param pattern [Regexp] a pattern to test for
      # @option opt [Fixnum] :occurrence (0) 0 for the first, 1 for the second, and so on
      # @yieldparam scanner [FileScanner] a file scanner
      # @yieldreturn [Object]
      # @return [Object,nil] the return value of the block, or +nil+ if the pattern was not found
      def self.scan(filename, pattern, opt={}, &block)
        s = new filename
        val = if s.read_until pattern, opt[:occurrence] || 0
          block.call s
        else
          nil
        end
        s.close
        val
      end

      def win_fudge
        (@f.lineno - 1) * @win_fudge
      end
      
      # Remember this position. A later call to insert_at_mark will insert at this marked position
      # @return [nil]
      def mark!
        @mark = @f.pos - win_fudge
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
      # @return [Boolean] whether or not a match was found. Use {#match} to retrieve the match data
      def read_until(pattern, n=0)
        i = 0
        mark!
        while (line = @f.readline) && i <= n
          if @match = pattern.match(line)
            return true if i == n
            i += 1
          end
          mark!
        end
      rescue EOFError
        unmark!
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
        @cap_begin_pos = @f.pos - win_fudge
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
          @cap_end_pos = @f.pos # win_fudge not needed here
          @cap_end_lineno = @f.lineno
        end
      rescue EOFError
        false
      end
      
      # @return [String] text captured during capture_until. The last newline is stripped
      def captured_text
        x = @lines.join('')
        x
      end
      
      # @param value [String] value to replace the captured_text with
      # @param opt [Boolean] :once (false) if once, the cog delimiters will be removed
      # @return [Boolean] whether or not the operation succeeded
      def replace_captured_text(value, opt={})
        return false if @cap_begin_pos.nil? || @cap_end_pos.nil?
        @f.seek 0
        @f.lineno = 0
        tmp.write @f.read(opt[:once] ? @mark : @cap_begin_pos)
        tmp.write value
        @f.seek @cap_end_pos
        @f.lineno = @cap_end_lineno
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
        @f.lineno = 0
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
        unless @tmp
          @tmp = File.open(tmp_filename, 'w')
          @tmp = @tmp.binmode if @tmp.respond_to?(:binmode)
        end
        @tmp
      end
    end
    
  end
end
