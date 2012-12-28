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
      @cog.run(:init).should_not do_something
    end
    
    it 'running `cog generator` should not list anything' do
      @cog.run(:generator).should_not do_something
    end
      
    it 'running `cog generator new` should do nothing' do
      @cog.run(:generator, :new).should_not do_something
    end
    
    it 'running `cog generator new piggy` should create a generator named piggy' do
      @cog.run(:generator, :new, :piggy).should make(generator(:piggy))
    end
    
    it 'running `cog template new piggy.txt` should create a template named piggy.txt.erb' do
      @cog.run(:template, :new, 'piggy.txt').should make(template('piggy.txt.erb'))
    end
    
    it 'running `cog template new warning` should override the built-in template' do
      @cog.run(:template, :new, 'warning').should_not complain
      File.read(template('warning.erb')).should_not be_empty
    end
  end
  
  describe 'which have a cogfile that is missing paths' do
    before :each do
      use_fixture :missing_project_paths
      use_home_fixture :empty
    end
    
    it 'running `cog template new piggy.txt` should complain' do
      @cog.run(:template, :new, 'piggy.txt').should complain
    end

    it 'running `cog generator new piggy` should complain' do
      @cog.run(:generator, :new, :piggy).should complain
    end

    it 'running `cog plugin new piggy` should create a plugin in the current directory' do
      @cog.run(:plugin, :new, :piggy).should make('piggy/Cogfile')
    end
  end
  
end
