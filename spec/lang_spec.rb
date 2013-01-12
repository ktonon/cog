require 'cog/spec_helpers'

describe 'projects' do

  include Cog::SpecHelpers
  
  before :all do
    @cog = Cog::SpecHelpers::Runner.new
    use_home_fixture :empty
  end
  
  context 'which generate in multiple languages' do
    before :all do
      use_fixture :lang
      @cog.run(:gen).should make(generated_file('generated_warn.h'))
    end
    
    def read(ext)
      File.new(generated_file("generated_warn.#{ext}")).read
    end
    
    [:h, :c, :hpp, :cpp, :java, :cs, :js, 'c++', 'h++', 'cxx', 'hxx', 'm', 'mm'].each do |ext|
      it "#{ext} should generate c-style comments" do
        read(ext).should == "// WARNING"
      end
    end

    [:css].each do |ext|
      it "#{ext} should generate c-style multiline comments" do
        read(ext).should == "/* WARNING */"
      end
    end

    [:rb, :py, :pro, :pri].each do |ext|
      it "#{ext} should generate hash comments" do
        read(ext).should == "# WARNING"
      end
    end
    
    [:xml, :html].each do |ext|
      it "#{ext} should generate xml-style comments" do
        read(ext).should == '<!-- WARNING -->'
      end
    end
  end
  
end
