require 'cog/spec_helpers/runner'
require 'cog/spec_helpers/matchers'

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
    
    # @return [String] directory of the active fixture.
    def active_fixture_dir
      File.join spec_root, 'active_fixture'
    end
    
    # @return [String] directory of the active home fixture.
    def active_home_fixture_dir
      File.join spec_root, 'active_home_fixture'
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

    # @param name [String] template identifier (without the .erb extension)
    # @return [String] absolute file system path to the template
    def template(name)
      File.expand_path File.join(active_fixture_dir, 'cog', 'templates', name.to_s)
    end
    
    # @param name [String] plugin name
    # @return [String] absolute file system path to the plugin directory
    def plugin(name)
      File.expand_path File.join(active_fixture_dir, 'cog', 'plugins', name.to_s)
    end

    # @param filename [String] name of a generated source file
    # @return [String] absolute path to the generated file
    def generated_file(filename)
      File.expand_path File.join(active_fixture_dir, 'src', filename)
    end
    
    # The next cog spec will execute in a fresh copy of the given fixture
    # Fixture directories are stored in <tt>spec/fixtures</tt>.
    # @param name [String] name of the fixture
    # @return [nil]
    def use_fixture(name)
      path = File.join spec_root, 'fixtures', name.to_s
      copy_fixture path, active_fixture_dir
      Dir.chdir active_fixture_dir
      nil
    end
    
    # The next cog spec will execute in a fresh copy of the given home fixture
    # Home fixture directories are stored in <tt>spec/home_fixtures</tt>
    # @param name [String] name of the home fixture
    # @return [nil]
    def use_home_fixture(name)
      path = File.join spec_root, 'home_fixtures', name.to_s
      copy_fixture path, active_home_fixture_dir
      nil
    end
    
    private
    
    def copy_fixture(source, dest)
      if File.exists?(source) && File.directory?(source)
        FileUtils.rm_rf dest if File.exists? dest
        FileUtils.cp_r source, dest
      else
        throw :invalid_fixture_name
      end
    end
    
    public
    
    extend self
  end
end
