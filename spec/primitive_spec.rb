require 'cog'
require 'cog/spec_helpers'

describe 'Primitive types' do

  include Cog::SpecHelpers

  before :all do
    use_home_fixture :empty
    use_fixture :empty
  end
  
  before :each do
    Cog.prepare :force_reset => true
  end
  
  describe 'The C language' do
      
    before(:each) { Cog.activate_language 'c' }
      
    it 'should map each primitive to an identifier' do
      expect(:boolean.to_prim).to eq('bool')
      expect(:integer.to_prim).to eq('int')
      expect(:long.to_prim).to eq('long')
      expect(:float.to_prim).to eq('float')
      expect(:double.to_prim).to eq('double')
      expect(:char.to_prim).to eq('char')
      expect(:string.to_prim).to eq('char *')
      expect(:null.to_prim).to eq('void *')
    end

    it 'should map ruby objects to literals' do
      expect(1.to_lit).to eq('1')
      expect((2**15 - 1).to_lit).to eq('32767')
      expect((2**15).to_lit).to eq('32768l')
      expect(true.to_lit).to eq('true')
      expect(false.to_lit).to eq('false')
      expect(1.0.to_lit).to eq('1.0f')
      expect(-5.3.to_lit).to eq('-5.3f')
      expect('c'.to_lit).to eq('\'c\'')
      expect('fresh'.to_lit).to eq('"fresh"')
      expect(nil.to_lit).to eq('NULL')
    end
    
    it 'should escape reserved words' do
      expect('foo'.to_ident).to eq('foo')
      expect('auto'.to_ident).to eq('auto_')
      expect('_Packed'.to_ident).to eq('_Packed_')
    end
  end

  describe 'The C++ language' do
      
    before(:each) { Cog.activate_language 'c++' }
      
    it 'should map each primitive to an identifier' do
      expect(:boolean.to_prim).to eq('bool')
      expect(:integer.to_prim).to eq('int')
      expect(:long.to_prim).to eq('long')
      expect(:float.to_prim).to eq('float')
      expect(:double.to_prim).to eq('double')
      expect(:char.to_prim).to eq('char')
      expect(:string.to_prim).to eq('std::string')
      expect(:null.to_prim).to eq('void *')
    end

    it 'should map ruby objects to literals' do
      expect(1.to_lit).to eq('1')
      expect((2**15 - 1).to_lit).to eq('32767')
      expect((2**15).to_lit).to eq('32768l')
      expect(true.to_lit).to eq('true')
      expect(false.to_lit).to eq('false')
      expect(1.0.to_lit).to eq('1.0f')
      expect('c'.to_lit).to eq('\'c\'')
      expect('fresh'.to_lit).to eq('"fresh"')
      expect(nil.to_lit).to eq('NULL')
    end

    it 'should escape reserved words' do
      expect('foo'.to_ident).to eq('foo')
      expect('MAX_RAND'.to_ident).to eq('MAX_RAND_')
      expect('virtual'.to_ident).to eq('virtual_')
    end
  end

  describe 'The C# language' do
      
    before(:each) { Cog.activate_language 'c#' }
      
    it 'should map each primitive to an identifier' do
      expect(:boolean.to_prim).to eq('bool')
      expect(:integer.to_prim).to eq('int')
      expect(:long.to_prim).to eq('long')
      expect(:float.to_prim).to eq('float')
      expect(:double.to_prim).to eq('double')
      expect(:char.to_prim).to eq('char')
      expect(:string.to_prim).to eq('string')
      expect(:null.to_prim).to eq('Object')
    end

    it 'should map ruby objects to literals' do
      expect(1.to_lit).to eq('1')
      expect((2**31 - 1).to_lit).to eq('2147483647')
      expect((2**31).to_lit).to eq('2147483648L')
      expect(true.to_lit).to eq('true')
      expect(false.to_lit).to eq('false')
      expect(1.0.to_lit).to eq('1.0F')
      expect('c'.to_lit).to eq('\'c\'')
      expect('fresh'.to_lit).to eq('"fresh"')
      expect(nil.to_lit).to eq('null')
    end

    it 'should escape reserved words' do
      expect('foo'.to_ident).to eq('foo')
      expect('unchecked'.to_ident).to eq('unchecked_')
      expect('virtual'.to_ident).to eq('virtual_')
    end
  end

  describe 'The Java language' do
      
    before(:each) { Cog.activate_language 'java' }
      
    it 'should map each primitive to an identifier' do
      expect(:boolean.to_prim).to eq('boolean')
      expect(:integer.to_prim).to eq('int')
      expect(:long.to_prim).to eq('long')
      expect(:float.to_prim).to eq('float')
      expect(:double.to_prim).to eq('double')
      expect(:char.to_prim).to eq('char')
      expect(:string.to_prim).to eq('String')
      expect(:null.to_prim).to eq('Object')
    end

    it 'should map ruby objects to literals' do
      expect(1.to_lit).to eq('1')
      expect((2**31 - 1).to_lit).to eq('2147483647')
      expect((2**31).to_lit).to eq('2147483648L')
      expect(true.to_lit).to eq('true')
      expect(false.to_lit).to eq('false')
      expect(1.0.to_lit).to eq('1.0f')
      expect('c'.to_lit).to eq('\'c\'')
      expect('fresh'.to_lit).to eq('"fresh"')
      expect(nil.to_lit).to eq('null')
    end

    it 'should escape reserved words' do
      expect('foo'.to_ident).to eq('foo')
      expect('assert'.to_ident).to eq('assert_')
      expect('transient'.to_ident).to eq('transient_')
    end
  end

  describe 'The JavaScript language' do
      
    before(:each) { Cog.activate_language 'javascript' }
      
    it 'should map each primitive to an identifier' do
      expect(:boolean.to_prim).to eq('Boolean')
      expect(:integer.to_prim).to eq('Number')
      expect(:long.to_prim).to eq('Number')
      expect(:float.to_prim).to eq('Number')
      expect(:double.to_prim).to eq('Number')
      expect(:char.to_prim).to eq('String')
      expect(:string.to_prim).to eq('String')
      expect(:null.to_prim).to eq('Object')
    end

    it 'should map ruby objects to literals' do
      expect(1.to_lit).to eq('1')
      expect((2**31 - 1).to_lit).to eq('2147483647')
      expect((2**31).to_lit).to eq('2147483648')
      expect(true.to_lit).to eq('true')
      expect(false.to_lit).to eq('false')
      expect(1.0.to_lit).to eq('1.0')
      expect('c'.to_lit).to eq('"c"')
      expect('fresh'.to_lit).to eq('"fresh"')
      expect(nil.to_lit).to eq('null')
    end

    it 'should escape reserved words' do
      expect('foo'.to_ident).to eq('foo')
      expect('Math'.to_ident).to eq('Math_')
      expect('var'.to_ident).to eq('var_')
    end
  end

  describe 'The Objective-C language' do
      
    before(:each) { Cog.activate_language 'objc' }
      
    it 'should map each primitive to an identifier' do
      expect(:boolean.to_prim).to eq('BOOL')
      expect(:integer.to_prim).to eq('int')
      expect(:long.to_prim).to eq('long')
      expect(:float.to_prim).to eq('float')
      expect(:double.to_prim).to eq('double')
      expect(:char.to_prim).to eq('char')
      expect(:string.to_prim).to eq('NSString *')
      expect(:null.to_prim).to eq('id')
    end

    it 'should map ruby objects to literals' do
      expect(1.to_lit).to eq('1')
      expect((2**15 - 1).to_lit).to eq('32767')
      expect((2**15).to_lit).to eq('32768l')
      expect(true.to_lit).to eq('YES')
      expect(false.to_lit).to eq('NO')
      expect(1.0.to_lit).to eq('1.0f')
      expect('c'.to_lit).to eq('\'c\'')
      expect('fresh'.to_lit).to eq('@"fresh"')
      expect(nil.to_lit).to eq('nil')
    end

    it 'should escape reserved words' do
      expect('foo'.to_ident).to eq('foo')
      expect('@class'.to_ident).to eq('@class_')
      expect('retain'.to_ident).to eq('retain_')
    end
  end

  describe 'The Python language' do
      
    before(:each) { Cog.activate_language 'python' }
      
    it 'should map each primitive to an identifier' do
      expect(:boolean.to_prim).to eq('bool')
      expect(:integer.to_prim).to eq('int')
      expect(:long.to_prim).to eq('int')
      expect(:float.to_prim).to eq('float')
      expect(:double.to_prim).to eq('float')
      expect(:char.to_prim).to eq('str')
      expect(:string.to_prim).to eq('str')
      expect(:null.to_prim).to eq('object')
    end

    it 'should map ruby objects to literals' do
      expect(1.to_lit).to eq('1')
      expect((2**15 - 1).to_lit).to eq('32767')
      expect((2**15).to_lit).to eq('32768')
      expect(true.to_lit).to eq('True')
      expect(false.to_lit).to eq('False')
      expect(1.0.to_lit).to eq('1.0')
      expect('c'.to_lit).to eq('"c"')
      expect('fresh'.to_lit).to eq('"fresh"')
      expect(nil.to_lit).to eq('None')
    end

    it 'should escape reserved words' do
      expect('foo'.to_ident).to eq('foo')
      expect('None'.to_ident).to eq('None_')
      expect('class'.to_ident).to eq('class_')
    end
  end

  describe 'The Ruby language' do
      
    before(:each) { Cog.activate_language 'ruby' }
      
    it 'should map each primitive to an identifier' do
      expect(:boolean.to_prim).to eq('!!')
      expect(:integer.to_prim).to eq('Fixnum')
      expect(:long.to_prim).to eq('Fixnum')
      expect(:float.to_prim).to eq('Float')
      expect(:double.to_prim).to eq('Float')
      expect(:char.to_prim).to eq('String')
      expect(:string.to_prim).to eq('String')
      expect(:null.to_prim).to eq('Object')
    end

    it 'should map ruby objects to literals' do
      expect(1.to_lit).to eq('1')
      expect((2**15 - 1).to_lit).to eq('32767')
      expect((2**15).to_lit).to eq('32768')
      expect(true.to_lit).to eq('true')
      expect(false.to_lit).to eq('false')
      expect(1.0.to_lit).to eq('1.0')
      expect('c'.to_lit).to eq('"c"')
      expect('fresh'.to_lit).to eq('"fresh"')
      expect(nil.to_lit).to eq('nil')
    end

    it 'should escape reserved words' do
      expect('foo'.to_ident).to eq('foo')
      expect('__FILE__'.to_ident).to eq('__FILE___')
      expect('unless'.to_ident).to eq('unless_')
    end
  end
  
end
