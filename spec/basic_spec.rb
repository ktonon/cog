require 'cog/spec_helpers'

describe 'cog' do

  include Cog::SpecHelpers
  
  before :all do
    @cog = Cog::SpecHelpers::Runner.new
    use_home_fixture :empty
  end
  
  it 'should print help when no args are passed' do
    expect(@cog.run).to show_help
  end
  
end
