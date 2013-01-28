require 'cog/spec_helpers'

describe 'seeds' do

  include Cog::SpecHelpers
  
  before :all do
    @cog = Cog::SpecHelpers::Runner.new
  end
  
  before :each do
    use_fixture :seeds
    use_home_fixture :empty
  end

  it 'stuff' do
    @cog.run(:gen).should_not complain
    # Open3.popen3 'make' do |i,o,e,t|
    #   block.call i,o,e
    #   e.should
    # end
    
  end

end
