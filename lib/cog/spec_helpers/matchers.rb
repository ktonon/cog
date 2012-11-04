require 'cog/spec_helpers/matchers/match_maker'
require 'rspec'

module Cog
  module SpecHelpers
    
    # Extra should or should_not matchers for RSpec.
    # Check out #match_maker for help writing new matchers.
    module Matchers
      
      # The target Invocation should write something to STDERR, indicating an error
      def complain
        match_maker do
          message { "to [write something|not write anything] to STDERR" }
          test { !error.empty? }
        end
      end

      # The target Invocation should create a +Cogfile+ where none existed before
      def make(path)
        match_maker do
          message { "to [create|not create] #{path}" }
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
          message { "to [write something|not write anything] to STDOUT" }
          test { !lines.empty? }
        end
      end
      
      # The target Invocation should write the given list of lines to standard output
      def output(x)
        match_maker do
          message { "to [write|not write] #{x.join "\n"} to STDOUT"}
          test do
            lines.zip(x).all? {|a, b| a.strip == b.to_s.strip}
          end
        end
      end
      
      # The target Invocation should output the default help text
      def show_help
        match_maker do
          message { "to [show|not show] the default help text, got #{lines.first.inspect}" }
          test { (/help.*code gen/ =~ lines[1]) }
        end
      end
      
    end
  end
end

RSpec.configure do |config|
  config.include Cog::SpecHelpers::Matchers
end
