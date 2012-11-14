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
  
    it 'running `cog generator new piggy` will fail' do
      @cog.run(:generator, :new, :piggy).should complain
    end
    
    it 'running `cog run` will fail' do
      @cog.run(:generator, :run).should complain
    end
    
    it 'running `cog tool` will not fail' do
      @cog.run(:tool).should_not complain
    end
    
    it 'running `cog template` will not fail' do
      @cog.run(:template).should_not complain
    end
    
    it 'running `cog template new piggy.txt` will fail' do
      @cog.run(:template, :new , 'piggy.txt').should complain
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
  
  context 'in a project which generates in multiple languages' do
    before :each do
      use_fixture :lang
    end
    
    def read(ext)
      File.new(generated_file("generated_warn.#{ext}")).read
    end
    
    it 'should determine the language based on the template extension' do
      @cog.run(:gen, :run).should make(generated_file('generated_warn.h'))
      [:h, :c, :hpp, :cpp, :java, :cs, :php, :js].each do |ext|
        read(ext).should == "/*\nWARNING\n */"
      end
      read(:rb).should == "=begin\nWARNING\n=end"
      read(:py).should == "'''\nWARNING\n'''"
      File.new(generated_file("generated_warn")).read.should == 'WARNING'
    end
  end
  
  context 'without any custom tools' do
    before :all do
      @cog.tools = []
    end
    
    it 'running `cog tool` should only list the built-in tools' do
      @cog.run(:tool).should output([:basic])
    end
  end
  
  context 'with a tool installed' do
    before :all do
      @cog.tools = [tool(:beef)]
    end
    
    it 'running `cog tool` should list that tool and the built-in tools in alphabetical order' do
      @cog.run(:tool).should output([:basic, :beef])
    end
  end
  
  context 'with a bad tool path' do
    before :all do
      @cog.tools = ['/bad/tool/path.rb']
    end
    
    it 'running `cog tool` should complain about a poorly configured tool path' do
      @cog.run(:tool).should complain
    end
  end
  
end
