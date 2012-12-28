module Cog
  module SpecHelpers
    module Matchers
      
      # Within {Matchers#match_maker} blocks, +self+ is set to an instance of this
      # class
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
        # be replaced with the appropriate section.
        #
        # @example
        #   message { "to [show|not show] the default help text" }
        # 
        # would read "expected cog to show the default help text"
        # for a positive failure and "expected cog to not show the
        # default help text" for a negative failure. The "expected cog"
        # part is inserted automatically.
        #
        # @yield called after the invocation. {#lines} and {#error} can be used
        # @return [nil]
        def message(&block)
          @msg_block = block
          nil
        end
        
        # Define a block which runs before the Invocation.
        #
        # This is not required, but can be used to save context that is used
        # the in post invocation #test.
        #
        # @yield called before the invocation. Save context as instance variables
        # @return [nil]
        def before(&block)
          @before_block = block
          nil
        end
        
        # Define the test which runs after the Invocation
        #
        # This can make use of instance variables set during #before.
        #
        # @yield called after the invocation
        # @return [nil]
        def test(&block)
          @test_block = block
          nil
        end
        
        # @api developer
        # @param invocation [Invocation] +cog+ executable and arguments bundled up
        # @return [Boolean] result of the {#test} block
        def matches?(invocation)
          @invocation = invocation
          instance_eval &@before_block unless @before_block.nil?
          @invocation.exec do |input, output, error|
            @lines = output.readlines
            @error = error.readlines
          end
          instance_eval &@test_block
        end

        # @api developer
        # @return [String] positive interpretation of the {#message} block result
        def failure_message
          _failure_message '\1'
        end
        
        # @api developer
        # @return [String] negative interpretation of the {#message} block result
        def negative_failure_message
          _failure_message '\2'
        end
        
        # @api developer
        # @return [String] STDOUT and STDERR
        def trace
          "STDOUT:\n#{@lines.join "\n"}\nSTDERR:\n#{@error.join "\n"}"
        end
        
        private
        
        def _failure_message(repl)
          msg = instance_eval &@msg_block
          msg = msg.gsub /\[([^\|\]]*)(?:\|([^\]]*)\])?/, repl
          "expected #{@invocation} #{msg}\n#{trace}"
        end
      end
      
      # Makes it easier to write RSpec matchers for testing +cog+ command invocations
      # @yield +self+ is set to an instance of {MatchMaker}
      # @example
      #   def show_help
      #     match_maker do
      #       message { "to [show|not show] the default help text, got #{lines.first.inspect}" }
      #       test { (/help.*code gen/ =~ lines[1]) }
      #     end
      #   end
      def match_maker(&block)
        m = MatchMaker.new
        m.instance_eval &block
        m
      end
      
    end
  end
end
