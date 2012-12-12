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
      @cog.run(:gen, :fruit).should_not complain
      read('app.pro').should =~ /apple[.]c orange[.]c pear[.]c/
      read('main.c').should =~ /include "apple.h"/
    end
    
    it 'should make use of context' do
      @cog.run(:gen, :contextual).should_not complain
      x = read('main.c')
      x.should =~ /filename is main.c/
      x.should =~ /lineno is 1/
      x.should =~ /body was one/
      x.should =~ /extension is c/
      x.should =~ /\/\/ this is a comment/
      x.should =~ /orange\-3\-cat/
      x.should =~ /contextual is once/
    end
    
    it 'should replace once directives with content only (i.e. remove the directive)' do
      @cog.run(:gen, :one_time).should_not complain
      x = read('main.c')
      x.should =~ /one-time stuff/
      x.should_not =~ /snippet\(one-time\)/
    end

    it 'should replace once directives that already have content with new content only' do
      directive = /one-time-body/
      read('main.c').should =~ directive
      @cog.run(:gen, :one_time_body).should_not complain
      x = read('main.c')
      x.should_not =~  directive
      x.should =~ /one time replacement/
      x.should_not =~ /one time replacement\n\/\/ cog\: \}/m
    end

    it 'should replace once directives that already have content with content only even if content has not changed' do
      directive = /one-time-same-body/
      body = /one time same body/
      x = read('main.c')
      x.should =~ directive
      x.should =~ body
      @cog.run(:gen, :one_time_same_body).should_not complain
      x = read('main.c')
      x.should_not =~ directive
      x.should =~ body
      x.should_not =~ /one time same body\n\/\/ cog\: \}/m
    end
    
    it 'should tolerate /* cog: snippet(multiline-style-comment-delimiters) */' do
      @cog.run(:gen, :multiline).should_not complain
      read('main.c').should =~ /multiline stuff/
    end
    
    it 'should tolerate spacing in the directive' do
      @cog.run(:gen, :spaces).should_not complain
      read('main.c').should =~ /spaces stuff/
    end
    
    it 'should tolerate //cog:snippet(compact-style-spacing)' do
      @cog.run(:gen, :compact).should_not complain
      read('main.c').should =~ /compact stuff/
    end
    
    it 'should correct spacing when expanding for the first time' do
      @cog.run(:gen, :spaces, :compact).should_not complain
      x = read('main.c')
      x.should =~ /\/\/ cog: snippet\(spaces\) \{$/
      x.should =~ /\/\/ cog: snippet\(compact\) \{$/
    end
    
    it 'should replace snippet expansions which differ' do
      @cog.run(:gen, :replace).should do_something
      read('main.c').should =~ /replace stuff/
    end
    
    it 'should not replace snippet expansions which have not changed' do
      @cog.run(:gen, :same).should_not do_something
      read('main.c').should =~ /same stuff/
    end
    
    it 'should replace all occurrences if the same snippet appears more than once in one file' do
      @cog.run(:gen, :twice).should do_something
      count = 0
      read('main.c').scan(/twice stuff/) do
        count += 1
      end
      count.should == 2
    end
    
    it 'should complain if the expansion terminator is expected and missing' do
      @cog.run(:gen, :missing_terminator).should complain
      read('main.c').should_not =~ /missing-terminator stuff/
    end
  end
  
end
