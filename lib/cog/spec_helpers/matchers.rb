require 'cog/spec_helpers/matchers/match_maker'
require 'rspec'

module Cog
  module SpecHelpers
    
    # Extra should or should_not matchers for RSpec.
    # Check out #match_maker for help writing new matchers.
    module Matchers
      
      # The target Invocation should complain about a missing +Cogfile+
      def complain_about_missing_cogfile
        match_maker do
          message { "to [require|not require] a Cogfile. STDOUT: #{lines.inspect}" }
          test { (/no cogfile could be found/i =~ lines.first) }
        end
      end

      # The target Invocation should create a +Cogfile+ where none existed before
      def make(path)
        match_maker do
          message { "to [create|not create] #{path}. STDOUT: #{lines.inspect}" }
          before do
            @existed = File.exists? path
          end
          test do
            !@existed && File.exists?(path)
          end
        end
      end
      
      # The target Invocation should do something, as determined by standard output
      def do_something
        match_maker do
          message { "to [write something|not write anything] to stdout. STDOUT: #{lines.inspect}" }
          test { !lines.empty? }
        end
      end
      
      # The target Invocation should output the default help text
      def show_help
        match_maker do
          message { "to [show|not show] the default help text, got #{lines.first.inspect}. STDOUT: #{lines.inspect}" }
          test { (/help.*code gen/ =~ lines[1]) }
        end
      end
      
    end
  end
end

RSpec.configure do |config|
  config.include Cog::SpecHelpers::Matchers
end
