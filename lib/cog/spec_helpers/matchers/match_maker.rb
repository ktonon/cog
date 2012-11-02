module Cog
  module SpecHelpers
    module Matchers
      
      class MatchMaker
        attr_reader :lines

        # Define the failure message
        def message(&block)
          @msg_block = block
        end
        
        # Define a block which runs before the Invocation
        def before(&block)
          @before_block = block
        end
        
        # Define the test which runs after the Invocation
        def test(&block)
          @test_block = block
        end
        
        def matches?(runner) # :nodoc:
          @runner = runner
          instance_eval &@before_block unless @before_block.nil?
          @runner.exec do |input, output, error|
            @lines = output.readlines
          end
          instance_eval &@test_block
        end
        def failure_message # :nodoc:
          msg = instance_eval &@msg_block
          msg = msg.gsub /\[([^\|\]]*)(?:\|([^\]]*)\])?/, '\1'
          "expected #{@runner} #{msg}"
        end
        def negative_failure_message # :nodoc:
          msg = instance_eval &@msg_block
          msg = msg.gsub /\[([^\|\]]*)(?:\|([^\]]*)\])?/, '\2'
          "expected #{@runner} #{msg}"
        end
      end
      
      def match_maker(&block)
        m = MatchMaker.new
        m.instance_eval &block
        m
      end
      
    end
  end
end
