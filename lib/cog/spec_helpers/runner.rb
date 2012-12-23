require 'open3'

module Cog
  module SpecHelpers

    # Points to the +cog+ command-line app
    class Runner

      # @param path_to_cl_app [String] path 
      def initialize
        @cog = File.expand_path File.join(File.dirname(__FILE__), '..', '..', '..', 'bin', 'cog')
      end

      # Run cog with the given arguments
      # @param args [Array<String>] arguments to pass to +cog+
      # @return [Invocation] an object which can be used with custom {Matchers}
      def run(*args)
        args = [@cog, '--colorless'] + args
        Invocation.new(args.collect {|x| x.to_s})
      end
    end
    
    # Represents a +cog+ command line invocation, which can be tested with
    # +RSpec+ +should+ and +should_not+ custom {Matchers}. This is the kind of
    # object returned by {Runner#run}.
    class Invocation
      
      # @api developer
      # @param cmd [Array<String>] path to +cog+ executable and arguments
      def initialize(cmd, opt={})
        @cmd = cmd
      end
      
      # Execute the command
      # @api developer
      # @yield [stdin, stdout, stderr] standard pipes for the invocation
      # @return [nil]
      def exec(&block)
        @cmd = ['bundle', 'exec'] + @cmd
        ENV['HOME'] = SpecHelpers.active_home_fixture_dir
        Open3.popen3 *@cmd do |i,o,e,t|
          block.call i,o,e
        end
      end

      # @api developer
      # @return [String] loggable representation
      def to_s
        "`#{@cmd.compact.join ' '}`"
      end
    end
    
  end
end
