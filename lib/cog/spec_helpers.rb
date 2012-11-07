require 'cog/spec_helpers/runner'
require 'cog/spec_helpers/matchers'
require 'fileutils'

module Cog
  
  # Modules and classes to help write specs for testing +cog+
  #
  # Requiring the helpers will make extra {SpecHelpers::Matchers} available to
  # your RSpec tests. These are useful for testing a {SpecHelpers::Invocation},
  # which is returned from a call to {SpecHelpers::Runner#run}
  #
  # @example
  #   require 'cog/spec_helpers'
  # 
  #   describe 'The command line interface' do
  # 
  #     include Cog::SpecHelpers
  #
  #     before :all do
  #       @cog = Cog::SpecHelpers::Runner.new 'bin/cog'
  #     end
  # 
  #     it 'should print help when no args are passed' do
  #       @cog.run.should show_help
  #     end
  #
  #     context 'in an uninitialized project' do
  #
  #       before :each do
  #         use_fixture :uninitialized
  #       end
  # 
  #       it 'running `cog init` should make a Cogfile' do
  #         @cog.run(:init).should make(cogfile_path)
  #       end
  #
  #     end
  #   end
  module SpecHelpers

    # @return [String] absolute path to the root spec directory
    def spec_root
      File.expand_path File.join(File.dirname(__FILE__), '..', '..', 'spec')
    end
    
    # @return [String] directory of an active spec fixture.
    def active_fixture_dir
      File.join spec_root, 'active_fixture'
    end

    # @return [String] path to the Cogfile in the active spec fixture
    def cogfile_path
      File.join active_fixture_dir, 'Cogfile'
    end
    
    # @return [String] path to the cog directory in the active spec fixture
    def cog_directory
      File.join active_fixture_dir, 'cog'
    end
    
    # @param name [String] active fixture generator identifier
    # @return [String] path to the generator with the given name
    def generator(name)
      File.expand_path File.join(active_fixture_dir, 'cog', 'generators', "#{name}.rb")
    end
    
    # @param name [String] tool fixture identifier
    # @return [String] path to the test tool with the given name
    def tool(name)
      File.expand_path File.join(spec_root, 'tools', name.to_s, 'lib', "#{name}.rb")
    end
    
    # The next cog spec will execute in a fresh copy of the given fixture
    # Fixture directories are stored in <tt>spec/fixtures</tt>.
    # @param name [String] name of the fixture
    # @return [nil]
    def use_fixture(name)
      path = File.join spec_root, 'fixtures', name.to_s
      if File.exists?(path) && File.directory?(path)
        FileUtils.rm_rf active_fixture_dir if File.exists? active_fixture_dir
        FileUtils.cp_r path, active_fixture_dir
        Dir.chdir active_fixture_dir
      else
        throw :invalid_fixture_name
      end
      nil
    end
    
  end
  
end
