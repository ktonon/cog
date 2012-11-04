require 'open3'

module Cog
  module SpecHelpers

    # Points to the +cog+ command-line app
    class Runner

      # Value of the COG_TOOLS environment variable for invocations returned from #run
      attr_accessor :tools
      
      def initialize(path_to_cl_app)
        @cog = File.expand_path path_to_cl_app
        @tools = []
      end

      # Run cog with the given arguments
      #
      # === Returns
      # An instance of Invocation configured with the arguments. Use should and
      # should_not with the custom Matchers
      def run(*args)
        args = [@cog] + args
        Invocation.new(args.collect {|x| x.to_s}, :tools => @tools)
      end
    end
    
    # Represents a +cog+ command line invocation, which can be tested with
    # +RSpec+ +should+ and +should_not+ custom Matchers. This is the kind of
    # object returned by Runner#run.
    class Invocation
      
      def initialize(cmd, opt={}) # :nodoc:
        @cmd = cmd
        @tools = opt[:tools].join ':'
      end
      
      def exec(*args, &block) # :nodoc:
        @cmd = ['bundle', 'exec'] + @cmd
        ENV['COG_TOOLS'] = @tools
        Open3.popen3 *@cmd do |i,o,e,t|
          block.call i,o,e
        end
      end

      def to_s # :nodoc:
        "`COG_TOOLS=#{@tools} #{@cmd.compact.join ' '}`"
      end
    end
    
  end
end
