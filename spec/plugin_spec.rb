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
      expect(@cog.run(:plugin)).to output(['[cog] basic'])
    end
    
    it 'running `cog plugin new foo` should create a new project plugin' do
      expect(@cog.run(:init)).to do_something
      expect(@cog.run(:plugin, :new, :foo)).to make(plugin(:foo))
      expect(@cog.run(:gen, :new, '-p', :foo, :bar)).to make(generator(:bar))
      expect(@cog.run(:gen)).to output(['TODO: write generator code for foo'])
    end
  end
  
  context 'with a user plugin installed' do
    it 'running `cog plugin` should list that plugin and the built-in plugins in alphabetical order' do
      use_home_fixture :plugins
      expect(@cog.run(:plugin)).to output(/\[cog\]\s+basic.*\[active_home_fixture\]\s+beef/m)
    end
  end
  
  context 'with a plugin path that does not exist' do
    it 'running `cog plugin` should complain' do
      use_home_fixture :plugin_path_dne
      expect(@cog.run(:plugin)).not_to complain
    end
  end
  
  context 'with a plugin path that is not a directory' do
    it 'running `cog plugin` should complain' do
      use_home_fixture :plugin_path_nd
      expect(@cog.run(:plugin)).to complain
    end
  end
  
end
