require 'cog/spec_helpers'

describe 'seeds' do

  include Cog::SpecHelpers
  
  before :all do
    @cog = Cog::SpecHelpers::Runner.new
    @make = Cog::SpecHelpers::Runner.new 'make', :flags => [], :use_bundler => false
    @trainer = Cog::SpecHelpers::Runner.new './trainer', :flags => [], :use_bundler => false
  end
  
  describe 'a sample seed called Dog' do
    before :each do
      use_fixture :seeds
      use_home_fixture :empty
    end

    it 'should generate C++ code that compiles' do
      @cog.run(:gen).should_not complain
      @make.run.should_not complain
    end

    it 'should compile an executable that runs' do
      @cog.run(:gen).should_not complain
      @make.run.should_not complain
      @trainer.run.should output(/A dog says: /)
    end
  end
end
