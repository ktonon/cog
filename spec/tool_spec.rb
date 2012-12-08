require 'cog/spec_helpers'

describe 'cog' do

  include Cog::SpecHelpers
  
  before :all do
    @cog = Cog::SpecHelpers::Runner.new
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
