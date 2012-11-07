require 'open3'

module Cog
  module SpecHelpers

    # Points to the +cog+ command-line app
    class Runner

      # Value of the COG_TOOLS environment variable for invocations returned from #run
      attr_accessor :tools
      
      # @param path_to_cl_app [String] path 
      def initialize(path_to_cl_app)
        @cog = File.expand_path path_to_cl_app
        @tools = []
      end

      # Run cog with the given arguments
      # @param args [Array<String>] arguments to pass to +cog+
      # @return [Invocation] an object which can be used with custom {Matchers}
      def run(*args)
        args = [@cog] + args
        Invocation.new(args.collect {|x| x.to_s}, :tools => @tools)
      end
    end
    
    # Represents a +cog+ command line invocation, which can be tested with
    # +RSpec+ +should+ and +should_not+ custom {Matchers}. This is the kind of
    # object returned by {Runner#run}.
    class Invocation
      
      # @api developer
      # @param cmd [Array<String>] path to +cog+ executable and arguments
      # @option opt [Array<String>] :tools ([]) a list of tools to add to the +COG_TOOLS+ environment variable just before running the command with {#exec}
      def initialize(cmd, opt={})
        @cmd = cmd
        @tools = (opt[:tools] || []).join ':'
      end
      
      # Execute the command
      # @api developer
      # @yield [stdin, stdout, stderr] standard pipes for the invocation
      # @return [nil]
      def exec(&block)
        @cmd = ['bundle', 'exec'] + @cmd
        ENV['COG_TOOLS'] = @tools
        Open3.popen3 *@cmd do |i,o,e,t|
          block.call i,o,e
        end
      end

      # @api developer
      # @return [String] loggable representation
      def to_s
        "`COG_TOOLS=#{@tools} #{@cmd.compact.join ' '}`"
      end
    end
    
  end
end
