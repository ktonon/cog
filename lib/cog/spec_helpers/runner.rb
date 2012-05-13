require 'open3'

module Cog
  module SpecHelpers

    # Points to the +cog+ command-line app
    class App

      def initialize(path_to_cl_app)
        @cog = path_to_cl_app
      end

      # Run cog with the given arguments
      #
      # === Returns
      # An instance of Invocation configured with the arguments. Use should and
      # should_not with the custom Matchers
      def run(*args)
        args.unshift @cog
        Invocation.new args
      end
    end
    
    # Represents a +cog+ command line invocation, which can be tested with
    # +RSpec+ +should+ and +should_not+ custom Matchers
    class Invocation
      
      def initialize(cmd) # :nodoc:
        @cmd = cmd
      end
      
      def exec(*args, &block) # :nodoc:
        Open3.popen3 *@cmd do |i,o,e,t|
          block.call i,o,e
        end
      end
      
    end
    
  end
end
