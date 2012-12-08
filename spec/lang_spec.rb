require 'cog/spec_helpers'

describe 'projects' do

  include Cog::SpecHelpers
  
  before :all do
    @cog = Cog::SpecHelpers::Runner.new
  end
  
  context 'which generate in multiple languages' do
    before :each do
      use_fixture :lang
    end
    
    def read(ext)
      File.new(generated_file("generated_warn.#{ext}")).read
    end
    
    it 'should determine the language based on the template extension' do
      @cog.run(:gen, :run).should make(generated_file('generated_warn.h'))
      [:h, :c, :hpp, :cpp, :java, :cs, :js].each do |ext|
        read(ext).should == "/*\nWARNING\n */"
      end
      read(:rb).should == "=begin\nWARNING\n=end"
      read(:py).should == "'''\nWARNING\n'''"
      File.new(generated_file("generated_warn")).read.should == 'WARNING'
    end
  end
  
end
