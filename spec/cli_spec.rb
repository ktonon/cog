require 'cog/spec_helpers'

describe 'The command line interface' do

  before :all do
    @cog = Cog::SpecHelpers::App.new 'bin/cog'
  end
  
  it 'should print help when no args are passed' do
    @cog.run.should show_help
  end
  
end
