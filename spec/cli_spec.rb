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
      @cog.run(:generator).should complain
    end
  
    it 'running `cog generator name` will fail' do
      @cog.run(:generator, :name).should complain
    end
    
    it 'running `cog run` will fail' do
      @cog.run(:run).should complain
    end
    
    it 'running `cog tool` will not fail' do
      @cog.run(:tool).should_not complain
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
  
  context 'without any tools installed' do
    before :all do
      @cog.tools = []
    end
    
    it 'running `cog tool` should not list anything' do
      @cog.run(:tool).should_not do_something
    end
  end
  
  context 'with a tool installed' do
    before :all do
      @cog.tools = [tool(:beef)]
    end
    
    it 'running `cog tool` should list that tool' do
      @cog.run(:tool).should output([:beef])
      @cog.run('-v', :tool).should output([tool(:beef)])
    end
  end
  
  context 'with a bad tool path' do
    before :all do
      @cog.tools = ['/bad/tool/path']
    end
    
    it 'running `cog tool` should complain about a poorly configured tool path' do
      @cog.run(:tool).should complain
    end
  end
  
end
