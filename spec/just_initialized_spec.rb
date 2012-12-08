require 'cog/spec_helpers'

describe 'projects' do

  include Cog::SpecHelpers
  
  before :all do
    @cog = Cog::SpecHelpers::Runner.new
  end
  
  describe 'which have just been initialized' do
    before :each do
      use_fixture :just_initialized
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

    it 'running `cog generator new piggy` should create c++ templates' do
      @cog.run(:generator, :new, :piggy).should make(template('piggy.cpp.erb'))
    end

    it 'running `cog generator new --language=c# piggy` should create c# templates' do
      @cog.run(:generator, :new, '--language=c#', :piggy).should make(template('piggy.cs.erb'))
    end
    
    it 'running `cog template new piggy.txt` should create a template named piggy.txt.erb' do
      @cog.run(:template, :new, 'piggy.txt').should make(template('piggy.txt.erb'))
    end
    
    it 'running `cog template new warning` should not override the built-in template' do
      @cog.run(:template, :new, 'warning').should complain
    end
      
    it 'running `cog template new --force-override warning` should override the built-in template' do
      @cog.run(:template, :new, '--force-override', 'warning').should make(template('warning.erb'))
    end
  end
  
end
