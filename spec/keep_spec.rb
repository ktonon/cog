require 'cog/spec_helpers'

describe 'generated files' do

  include Cog::SpecHelpers
  
  before :all do
    @cog = Cog::SpecHelpers::Runner.new
    use_home_fixture :empty
  end
  
  context 'which have keep statements' do
    before :all do
      use_fixture :keeps
    end
    
    def read(filename)
      File.new(generated_file(filename)).read
    end
    
    it "should keep them when they have bodies" do
      expect(File).to exist(generated_file('kept.c'))
      expect(@cog.run(:gen, :keeper)).not_to do_something
      w = read('kept.c')
      expect(w).to match(/keep this;/)
      expect(w).to match(/keep that;/)
    end

    it "should expand them when they do not" do
      expect(File).not_to exist(generated_file('expanded.c'))
      expect(@cog.run(:gen, :expander)).to do_something
      w = read('expanded.c')
      expect(w).to match(/\/\/ keep: func1 \{\n\n\/\/ keep: \}/m)
    end
    
    it "should fail when there are duplicate hooks" do
      expect(@cog.run(:gen, :duper)).to complain
      expect(File).not_to exist(generated_file('duped.c'))
    end

    it "should fail when keep hooks go missing" do
      expect(File).to exist(generated_file('fewer.c'))
      expect(@cog.run(:gen, :fewer)).to complain
    end

  end
end
