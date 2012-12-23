require 'cog/spec_helpers'

describe 'cog' do

  include Cog::SpecHelpers
  
  before :all do
    @cog = Cog::SpecHelpers::Runner.new
  end
  
  context 'without any custom plugins' do
    it 'running `cog plugin` should only list the built-in plugins' do
      use_home_fixture :empty
      @cog.run(:plugin).should output([:basic])
    end
  end
  
  context 'with a plugin installed' do
    it 'running `cog plugin` should list that plugin and the built-in plugins in alphabetical order' do
      use_home_fixture :plugins
      @cog.run(:plugin).should output([:basic, :beef])
    end
  end
  
  context 'with a plugin path that does not exist' do
    it 'running `cog plugin` should complain' do
      use_home_fixture :plugin_path_dne
      @cog.run(:plugin).should complain
    end
  end

  context 'with a plugin path that is not a directory' do
    it 'running `cog plugin` should complain' do
      use_home_fixture :plugin_path_nd
      @cog.run(:plugin).should complain
    end
  end
  
end
