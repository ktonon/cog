require 'cog'
require 'cog/spec_helpers'

describe Cog::Generator do

  include Cog::Generator
  include Cog::SpecHelpers

  describe '#stamp' do
    
    before :each do
      use_home_fixture :empty
      use_fixture 'with_generators'
      Cog.prepare :force_reset => true
      @cheeses = [:brie, :cheddar]
      @expected = @cheeses.collect {|c| "I like #{c} cheese.\n"}.join ''
    end
  
    it 'should not change the present working directory' do
      x = Dir.pwd
      stamp('cheese.txt')
      Dir.pwd.should == x
      stamp('cheese.txt', 'dest.text', :quiet => true)
      Dir.pwd.should == x
    end
    
    it 'should return a string when destination is omitted' do
      stamp('cheese.txt').should == @expected
    end
    
    it 'should return nil when a destination is provided' do
      stamp('cheese.txt', 'dest.txt', :quiet => true).should be(nil)
    end

    it 'should create a file when a destination is provided' do
      stamp('cheese.txt', 'dest.txt', :quiet => true)
      expect(File).to exist(generated_file 'dest.txt')
      File.new(generated_file 'dest.txt').read.should == @expected
    end

    it 'should accept absolute paths' do
      stamp template('cheese.txt'), 'dest1.txt', :absolute_template_path => true, :quiet => true
      stamp 'cheese.txt', generated_file('dest2.txt'), :absolute_destination => true, :quiet => true
      expect(File).to exist(generated_file 'dest1.txt')
      expect(File).to exist(generated_file 'dest2.txt')
    end
    
    it 'should be able to find built-in templates' do
      stamp('warning').should =~ /do not edit this/i
    end
    
  end
end
