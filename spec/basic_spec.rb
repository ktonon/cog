require 'cog/spec_helpers'

describe 'cog' do

  include Cog::SpecHelpers
  
  before :all do
    @cog = Cog::SpecHelpers::Runner.new
  end
  
  it 'should print help when no args are passed' do
    @cog.run.should show_help
  end
  
end
