require 'cog/spec_helpers'

describe 'projects' do

  include Cog::SpecHelpers
  
  before :all do
    @cog = Cog::SpecHelpers::Runner.new
  end
  
  context 'which use snippets' do
    before :each do
      use_fixture :snippet
    end
    
    def read(name)
      File.new(generated_file(name)).read
    end
    
    it 'should expand snippets with values provided' do
      @cog.run(:gen).should_not complain
      read('app.pro').should =~ /apple[.]c orange[.]c pear[.]c/
      read('main.c').should =~ /include "apple.h"/
    end
  end
  
end
