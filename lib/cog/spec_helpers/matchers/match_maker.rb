module Cog
  module SpecHelpers
    module Matchers
      
      # Within Matchers#match_maker blocks, +self+ is set to an instance of this
      # class.
      class MatchMaker

        # A list of lines read from STDOUT after executing the Invocation
        attr_reader :lines

        # A list of lines read from STDERR after executing the Invocation
        attr_reader :error

        # Define a block which runs after a test fails and should return
        # a failure message template.
        # 
        # The template is used for both positive and negative failures.
        # Substrings which look like this <tt>"[positive|negative]</tt>" will
        # be replaced with the appropriate section. For example
        #   message { "to [show|not show] the default help text" }
        # 
        # would read "expected cog to show the default help text"
        # for a positive failure and "expected cog to not show the
        # default help text" for a negative failure. The "expected cog"
        # part is inserted automatically.
        def message(&block)
          @msg_block = block
        end
        
        # Define a block which runs before the Invocation.
        #
        # This is not required, but can be used to save context that is used
        # the in post invocation #test.
        def before(&block)
          @before_block = block
        end
        
        # Define the test which runs after the Invocation
        #
        # This can make use of instance variables set during #before.
        def test(&block)
          @test_block = block
        end
        
        def matches?(runner) # :nodoc:
          @runner = runner
          instance_eval &@before_block unless @before_block.nil?
          @runner.exec do |input, output, error|
            @lines = output.readlines
            @error = error.readlines
          end
          instance_eval &@test_block
        end
        def failure_message # :nodoc:
          msg = instance_eval &@msg_block
          msg = msg.gsub /\[([^\|\]]*)(?:\|([^\]]*)\])?/, '\1'
          "expected #{@runner} #{msg}\n#{trace}"
        end
        def negative_failure_message # :nodoc:
          msg = instance_eval &@msg_block
          msg = msg.gsub /\[([^\|\]]*)(?:\|([^\]]*)\])?/, '\2'
          "expected #{@runner} #{msg}\n#{trace}"
        end
        
        def trace # :nodoc
          "STDOUT:\n#{@lines.join "\n"}\nSTDERR:\n#{@error.join "\n"}"
        end
      end
      
      # Makes it easy to write RSpec matchers
      #
      # Here is how the matcher for Matchers#show_help is written using this method
      # #match_maker method.
      #   def show_help
      #     match_maker do
      #       message { "to [show|not show] the default help text, got #{lines.first.inspect}" }
      #       test { (/help.*code gen/ =~ lines[1]) }
      #     end
      #   end
      #
      # Within the +match_maker+ block, +self+ is set to an instance of MatchMaker.
      def match_maker(&block)
        m = MatchMaker.new
        m.instance_eval &block
        m
      end
      
    end
  end
end
