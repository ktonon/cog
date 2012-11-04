require 'cog/spec_helpers'

describe 'The command line interface' do

  include Cog::SpecHelpers
  
  before :all do
    @cog = Cog::SpecHelpers::Runner.new 'bin/cog'
  end
  
  it 'should print help when no args are passed' do
    @cog.run.should show_help
  end
  
  context 'in an uninitialized project' do
    before :each do
      use_fixture :uninitialized
    end
    
    it 'running `cog init` should make a Cogfile' do
      @cog.run(:init).should make(cogfile_path)
    end
    
    it 'running `cog init` should make a cog directory' do
      @cog.run(:init).should make(cog_directory)
    end
    
    it 'running `cog generator` will fail' do
      @cog.run(:generator).should complain_about_missing_cogfile
    end

    it 'running `cog generator name` will fail' do
      @cog.run(:generator, :name).should complain_about_missing_cogfile
    end
    
    it 'running `cog run` will fail' do
      @cog.run(:run).should complain_about_missing_cogfile
    end
    
    it 'running `cog tool` will not fail' do
      @cog.run(:tool).should_not complain_about_missing_cogfile
    end
  end
  
  context 'in a project that has just been initialized' do
    before :each do
      use_fixture :just_initialized
    end
    
    it 'running `cog init` should not do anything' do
      @cog.run(:init).should_not do_something
    end
    
    it 'running `cog generator` should not list anything' do
      @cog.run(:generator).should_not do_something
    end
    
    it 'running `cog generator piggy` should create a generator named piggy' do
      @cog.run(:generator, :piggy).should make(generator(:piggy))
    end
  end
  
end
