require 'cog/spec_helpers'

describe 'projects' do

  include Cog::SpecHelpers
  
  before :all do
    @cog = Cog::SpecHelpers::Runner.new
  end
  
  describe 'which have not yet been initialized' do
    before :each do
      use_fixture :uninitialized
      use_home_fixture :empty
    end
    
    it 'running `cog init` should make a Cogfile' do
      expect(@cog.run(:init)).to make(cogfile_path)
    end
    
    it 'running `cog generator` do nothing' do
      expect(@cog.run(:generator)).not_to do_something
    end
  
    it 'running `cog generator new piggy` will fail' do
      expect(@cog.run(:generator, :new, :piggy)).to complain
    end
    
    it 'running `cog gen list` should list built-in generators' do
      expect(@cog.run(:generator, :list)).to output(/^\[cog\]\s+sort$/m)
    end
    
    it 'running `cog run` do nothing' do
      expect(@cog.run(:generator, :run)).not_to do_something
    end
    
    it 'running `cog plugin` should list built-in plugins' do
      expect(@cog.run(:plugin)).to output(/^\[cog\]\s+basic$/m)
    end

    it 'running `cog plugin new foo` should create a plugin in the current directory' do
      expect(@cog.run(:plugin, :new, :foo)).to make('foo/Cogfile')
    end
    
    it 'running `cog template` should list built-in templates' do
      expect(@cog.run(:template)).to output(/^\[cog\]\s+warning$/m)
    end
    
    it 'running `cog template new piggy.txt` will fail' do
      expect(@cog.run(:template, :new , 'piggy.txt')).to complain
    end
  end  
  
end
