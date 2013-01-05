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
      File.should exist(generated_file('kept.c'))
      @cog.run(:gen, :keeper).should_not do_something
      w = read('kept.c')
      w.should =~ /keep this;/
      w.should =~ /keep that;/
    end

    it "should expand them when they do not" do
      File.should_not exist(generated_file('expanded.c'))
      @cog.run(:gen, :expander).should do_something
      w = read('expanded.c')
      w.should =~ /\/\/ keep: func1 \{\n\n\/\/ keep: \}/m
    end
    
    it "should fail when there are duplicate hooks" do
      @cog.run(:gen, :duper).should complain
      File.should_not exist(generated_file('duped.c'))
    end

    it "should fail when keep hooks go missing" do
      File.should exist(generated_file('fewer.c'))
      @cog.run(:gen, :fewer).should complain
    end

  end
end
