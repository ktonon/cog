require 'cog/spec_helpers'

describe 'projects' do

  include Cog::SpecHelpers
  
  before :all do
    @cog = Cog::SpecHelpers::Runner.new
  end
  
  describe 'which have just been initialized' do
    before :each do
      use_fixture :just_initialized
      use_home_fixture :plugins
    end
    
    it 'running `cog init` should not do anything' do
      expect(@cog.run(:init)).not_to do_something
    end
    
    it 'running `cog generator` should not list anything' do
      expect(@cog.run(:generator)).not_to do_something
    end
      
    it 'running `cog generator new` should do nothing' do
      expect(@cog.run(:generator, :new)).not_to do_something
    end
    
    it 'running `cog generator new piggy` should create a generator named piggy' do
      expect(@cog.run(:generator, :new, :piggy)).to make(generator(:piggy))
    end
    
    it 'running `cog template new piggy.txt` should create a template named piggy.txt.erb' do
      expect(@cog.run(:template, :new, 'piggy.txt')).to make(template('piggy.txt.erb'))
    end
    
    it 'running `cog template new warning` should override the built-in template' do
      expect(@cog.run(:template, :new, 'warning')).not_to complain
      expect(File.read(template('warning.erb'))).not_to be_empty
    end
  end
  
  describe 'which have a cogfile that is missing paths' do
    before :each do
      use_fixture :missing_project_paths
      use_home_fixture :empty
    end
    
    it 'running `cog template new piggy.txt` should complain' do
      expect(@cog.run(:template, :new, 'piggy.txt')).to complain
    end

    it 'running `cog generator new piggy` should complain' do
      expect(@cog.run(:generator, :new, :piggy)).to complain
    end

    it 'running `cog plugin new piggy` should create a plugin in the current directory' do
      expect(@cog.run(:plugin, :new, :piggy)).to make('piggy/Cogfile')
    end
  end
  
end
