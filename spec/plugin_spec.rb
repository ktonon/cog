require 'cog/spec_helpers'

describe 'cog' do

  include Cog::SpecHelpers
  
  before :all do
    @cog = Cog::SpecHelpers::Runner.new
  end
  
  before :each do
    use_fixture :empty
  end
  
  context 'without any custom plugins' do
    before :each do
      use_home_fixture :empty
    end
    
    it 'running `cog plugin` should only list the built-in plugins' do
      @cog.run(:plugin).should output(['[cog] basic'])
    end
    
    it 'running `cog plugin new foo` should create a new project plugin' do
      @cog.run(:init).should do_something
      @cog.run(:plugin, :new, :foo).should make(plugin(:foo))
      @cog.run(:gen, :new, '-p', :foo, :bar).should make(generator(:bar))
      @cog.run(:gen).should output(['TODO: write generator code for foo'])
    end
  end
  
  context 'with a user plugin installed' do
    it 'running `cog plugin` should list that plugin and the built-in plugins in alphabetical order' do
      use_home_fixture :plugins
      @cog.run(:plugin).should output(['[cog]                 basic', '[active_home_fixture] beef'])
    end
  end
  
  context 'with a plugin path that does not exist' do
    it 'running `cog plugin` should complain' do
      use_home_fixture :plugin_path_dne
      @cog.run(:plugin).should_not complain
    end
  end
  
  context 'with a plugin path that is not a directory' do
    it 'running `cog plugin` should complain' do
      use_home_fixture :plugin_path_nd
      @cog.run(:plugin).should complain
    end
  end
  
end
