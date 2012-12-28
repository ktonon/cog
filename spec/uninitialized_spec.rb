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
      @cog.run(:init).should make(cogfile_path)
    end
    
    it 'running `cog generator` do nothing' do
      @cog.run(:generator).should_not do_something
    end
  
    it 'running `cog generator new piggy` will fail' do
      @cog.run(:generator, :new, :piggy).should complain
    end
    
    it 'running `cog run` do nothing' do
      @cog.run(:generator, :run).should_not do_something
    end
    
    it 'running `cog plugin` will not fail' do
      @cog.run(:plugin).should_not complain
    end

    it 'running `cog plugin new foo` will fail' do
      @cog.run(:plugin, :new, :foo).should complain
    end
    
    it 'running `cog template` will not fail' do
      @cog.run(:template).should_not complain
    end
    
    it 'running `cog template new piggy.txt` will fail' do
      @cog.run(:template, :new , 'piggy.txt').should complain
    end
  end  
  
end
