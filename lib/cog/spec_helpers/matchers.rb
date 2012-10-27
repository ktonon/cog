require 'rspec'

module Cog
  module SpecHelpers
    
    # Extra should or should_not matchers for RSpec.
    module Matchers
      
      class ShowHelp # :nodoc:
        def matches?(runner)
          @runner = runner
          @runner.exec do |i,o,e|
            @first_line = o.readline
            @second_line = o.readline
            /help.*code gen/ =~ @second_line
          end
        end
        def failure_message
          "expected #{@runner} to show the default help text, got #{@first_line.inspect}"
        end
        def negative_failure_message
          "expected #{@runner} to not show the default help text, got #{@first_line.inspect}"
        end
      end
      
      # The target Invocation should output the default help text
      def show_help
        ShowHelp.new
      end
    end
    
  end
end

RSpec.configure do |config|
  config.include Cog::SpecHelpers::Matchers
end
