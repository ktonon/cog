require 'open3'

module Cog
  module SpecHelpers

    # Points to the +cog+ command-line app
    class Runner

      def initialize(path_to_cl_app)
        @cog = File.expand_path path_to_cl_app
      end

      # Run cog with the given arguments
      #
      # === Returns
      # An instance of Invocation configured with the arguments. Use should and
      # should_not with the custom Matchers
      def run(*args)
        args = ['bundle', 'exec', @cog] + args
        Invocation.new(args.collect {|x| x.to_s})
      end
    end
    
    # Represents a +cog+ command line invocation, which can be tested with
    # +RSpec+ +should+ and +should_not+ custom Matchers
    class Invocation
      
      def initialize(cmd) # :nodoc:
        @cmd = cmd
      end
      
      def exec(*args, &block) # :nodoc:
        @s = ([File.basename @cmd[2]] + @cmd.slice(3..-1)).join ' '
        Open3.popen3 *@cmd do |i,o,e,t|
          block.call i,o,e
        end
      end

      def to_s
        "`#{@s}`"
      end
    end
    
  end
end
