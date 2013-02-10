require 'open3'

module Cog
  module SpecHelpers

    # Points to the +cog+ command-line app
    class Runner

      # @param exec_path [String] path to the executable
      # @option opt [Array<String>] :flags (['--colorless']) command line flags to pass each time the executable is invoked
      # @option opt [Boolean] :use_bundler (true) Should `bundle exec` prefix each invocation of the executable?
      def initialize(exec_path = nil, opt={})
        @exec_path = if exec_path
          exec_path
        else
          File.expand_path File.join(File.dirname(__FILE__), '..', '..', '..', 'bin', 'cog')
        end
        @flags = opt[:flags] || ['--colorless']
        @use_bundler = opt[:use_bundler].nil? ? true : opt[:use_bundler]
      end

      # Run cog with the given arguments
      # @param args [Array<String>] arguments to pass to +cog+
      # @return [Invocation] an object which can be used with custom {Matchers}
      def run(*args)
        cmd = ([@exec_path] + @flags + args).collect &:to_s
        Invocation.new(cmd, :use_bundler => @use_bundler)
      end
    end
    
    # Represents a +cog+ command line invocation, which can be tested with
    # +RSpec+ +should+ and +should_not+ custom {Matchers}. This is the kind of
    # object returned by {Runner#run}.
    class Invocation
      
      # @api developer
      # @param cmd [Array<String>]
      # @option opt [Boolean] :use_bundler (false)
      def initialize(cmd, opt={})
        @cmd = cmd
        @use_bundler = opt[:use_bundler]
      end
      
      # Execute the command
      # @api developer
      # @yield [stdin, stdout, stderr] standard pipes for the invocation
      # @return [nil]
      def exec(&block)
        full_cmd = @cmd
        full_cmd = ['bundle', 'exec'] + full_cmd if @use_bundler
        ENV['HOME'] = SpecHelpers.active_home_fixture_dir
        Open3.popen3 *full_cmd do |i,o,e,t|
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
