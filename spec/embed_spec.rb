require 'cog/spec_helpers'

describe 'projects' do

  include Cog::SpecHelpers
  
  before :all do
    @cog = Cog::SpecHelpers::Runner.new
    use_home_fixture :empty
  end
  
  context 'which use embeds' do
    before :each do
      use_fixture :embed
    end
    
    def read(name)
      File.new(generated_file(name)).read
    end
    
    it 'should expand embeds with values provided' do
      expect(@cog.run :gen, :fruit).not_to complain
      expect(read 'app.pro').to match(/apple[.]c orange[.]c pear[.]c/)
      expect(read 'main.c').to match(/include "apple.h"/)
    end
    
    it 'should make use of context' do
      expect(@cog.run(:gen, :contextual)).not_to complain
      x = read('main.c')
      expect(x).to match(/hook is contextual/)
      expect(x).to match(/filename is main.c/)
      expect(x).to match(/lineno is 1/)
      expect(x).to match(/body was one/)
      expect(x).to match(/extension is c/)
      expect(x).to match(/\/\/ this is a comment/)
      expect(x).to match(/orange\-3\-cat/)
      expect(x).to match(/contextual is once/)
      expect(x).to match(/only occurrence is first and last/)
      expect(x).to match(/only occurrence index is 0/)
      expect(x).to match(/only occurrence count is 1/)
    end
    
    it 'should have correct index and count context with multiple hooks' do
      expect(@cog.run(:gen, :context_many)).not_to complain
      x = read('main.c')
      expect(x).to match(/0 of 4 on line 5 is first but is not last/)
      expect(x).to match(/1 of 4 on line 19 is not first and is not last/)
      expect(x).to match(/2 of 4 on line 26 is not first and is not last/)
      expect(x).to match(/3 of 4 on line 38 is not first but is last/)
    end
    
    it 'should replace once embeds with content only (i.e. remove the directive)' do
      expect(@cog.run(:gen, :one_time)).not_to complain
      x = read('main.c')
      expect(x).to match(/one-time stuff/)
      expect(x).not_to match(/embed\(one-time\)/)
    end

    it 'should replace once embeds that already have content with new content only' do
      directive = /one-time-body/
      expect(read('main.c')).to match(directive)
      expect(@cog.run(:gen, :one_time_body)).not_to complain
      x = read('main.c')
      expect(x).not_to match(directive)
      expect(x).to match(/one time replacement/)
      expect(x).not_to match(/one time replacement\n\/\/ cog\: \}/m)
    end

    it 'should replace once embeds that already have content with content only even if content has not changed' do
      directive = /one-time-same-body/
      body = /one time same body/
      x = read('main.c')
      expect(x).to match(directive)
      expect(x).to match(body)
      expect(@cog.run(:gen, :one_time_same_body)).not_to complain
      x = read('main.c')
      expect(x).not_to match(directive)
      expect(x).to match(body)
      expect(x).not_to match(/one time same body\n\/\/ cog\: \}/m)
    end
    
    it 'should tolerate /* cog: embed(multiline-style-comment-delimiters) */' do
      expect(@cog.run(:gen, :multiline)).not_to complain
      expect(read('main.c')).to match(/multiline stuff/)
    end
    
    it 'should tolerate spacing in the directive' do
      expect(@cog.run(:gen, :spaces)).not_to complain
      expect(read('main.c')).to match(/spaces stuff/)
    end
    
    it 'should tolerate //cog:embed(compact-style-spacing)' do
      expect(@cog.run(:gen, :compact)).not_to complain
      expect(read('main.c')).to match(/compact stuff/)
    end
    
    it 'should correct spacing when expanding for the first time' do
      expect(@cog.run(:gen, :spaces, :compact)).not_to complain
      x = read('main.c')
      expect(x).to match(/\/\/ cog: spaces\(with args\) \{$/)
      expect(x).to match(/\/\/ cog: compact\(with args\) \{$/)
    end
    
    it 'should replace embed expansions which differ' do
      expect(@cog.run(:gen, :replace)).to do_something
      expect(read('main.c')).to match(/replace stuff/)
    end
    
    it 'should not replace embed expansions which have not changed' do
      expect(@cog.run(:gen, :same)).not_to do_something
      expect(read('main.c')).to match(/same stuff/)
    end
    
    it 'should replace all occurrences if the same embed appears more than once in one file' do
      expect(@cog.run(:gen, :twice)).to do_something
      count = 0
      read('main.c').scan(/twice stuff/) do
        count += 1
      end
      expect(count).to eq(2)
    end
    
    it 'should complain if the expansion terminator is expected and missing' do
      expect(@cog.run(:gen, :missing_terminator)).to complain
      expect(read('main.c')).not_to match(/missing-terminator stuff/)
    end
  end
  
end
