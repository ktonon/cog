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
      use_fixture :empty
    end
    
    it 'running `cog init` should make a Cogfile' do
      @cog.run(:init).should make(cogfile_path)
    end
    
    it 'running `cog init` should make a cog directory' do
      @cog.run(:init).should make(cog_directory)
    end
  end
  
end
