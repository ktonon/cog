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
      :boolean.to_prim.should == 'bool'
      :integer.to_prim.should == 'int'
      :long.to_prim.should == 'long'
      :float.to_prim.should == 'float'
      :double.to_prim.should == 'double'
      :char.to_prim.should == 'char'
      :string.to_prim.should == 'char *'
      :null.to_prim.should == 'void *'
    end

    it 'should map ruby objects to literals' do
      1.to_lit.should == '1'
      (2**15 - 1).to_lit.should == '32767'
      (2**15).to_lit.should == '32768l'
      true.to_lit.should == 'true'
      false.to_lit.should == 'false'
      1.0.to_lit.should == '1.0f'
      -5.3.to_lit.should == '-5.3f'
      'c'.to_lit.should == '\'c\''
      'fresh'.to_lit.should == '"fresh"'
      nil.to_lit.should == 'NULL'
    end
    
    it 'should escape reserved words' do
      'foo'.to_ident.should == 'foo'
      'auto'.to_ident.should == 'auto_'
      '_Packed'.to_ident.should == '_Packed_'
    end
  end

  describe 'The C++ language' do
      
    before(:each) { Cog.activate_language 'c++' }
      
    it 'should map each primitive to an identifier' do
      :boolean.to_prim.should == 'bool'
      :integer.to_prim.should == 'int'
      :long.to_prim.should == 'long'
      :float.to_prim.should == 'float'
      :double.to_prim.should == 'double'
      :char.to_prim.should == 'char'
      :string.to_prim.should == 'std::string'
      :null.to_prim.should == 'void *'
    end

    it 'should map ruby objects to literals' do
      1.to_lit.should == '1'
      (2**15 - 1).to_lit.should == '32767'
      (2**15).to_lit.should == '32768l'
      true.to_lit.should == 'true'
      false.to_lit.should == 'false'
      1.0.to_lit.should == '1.0f'
      'c'.to_lit.should == '\'c\''
      'fresh'.to_lit.should == '"fresh"'
      nil.to_lit.should == 'NULL'
    end

    it 'should escape reserved words' do
      'foo'.to_ident.should == 'foo'
      'MAX_RAND'.to_ident.should == 'MAX_RAND_'
      'virtual'.to_ident.should == 'virtual_'
    end
  end

  describe 'The C# language' do
      
    before(:each) { Cog.activate_language 'c#' }
      
    it 'should map each primitive to an identifier' do
      :boolean.to_prim.should == 'bool'
      :integer.to_prim.should == 'int'
      :long.to_prim.should == 'long'
      :float.to_prim.should == 'float'
      :double.to_prim.should == 'double'
      :char.to_prim.should == 'char'
      :string.to_prim.should == 'string'
      :null.to_prim.should == 'Object'
    end

    it 'should map ruby objects to literals' do
      1.to_lit.should == '1'
      (2**31 - 1).to_lit.should == '2147483647'
      (2**31).to_lit.should == '2147483648L'
      true.to_lit.should == 'true'
      false.to_lit.should == 'false'
      1.0.to_lit.should == '1.0F'
      'c'.to_lit.should == '\'c\''
      'fresh'.to_lit.should == '"fresh"'
      nil.to_lit.should == 'null'
    end

    it 'should escape reserved words' do
      'foo'.to_ident.should == 'foo'
      'unchecked'.to_ident.should == 'unchecked_'
      'virtual'.to_ident.should == 'virtual_'
    end
  end

  describe 'The Java language' do
      
    before(:each) { Cog.activate_language 'java' }
      
    it 'should map each primitive to an identifier' do
      :boolean.to_prim.should == 'boolean'
      :integer.to_prim.should == 'int'
      :long.to_prim.should == 'long'
      :float.to_prim.should == 'float'
      :double.to_prim.should == 'double'
      :char.to_prim.should == 'char'
      :string.to_prim.should == 'String'
      :null.to_prim.should == 'Object'
    end

    it 'should map ruby objects to literals' do
      1.to_lit.should == '1'
      (2**31 - 1).to_lit.should == '2147483647'
      (2**31).to_lit.should == '2147483648L'
      true.to_lit.should == 'true'
      false.to_lit.should == 'false'
      1.0.to_lit.should == '1.0f'
      'c'.to_lit.should == '\'c\''
      'fresh'.to_lit.should == '"fresh"'
      nil.to_lit.should == 'null'
    end

    it 'should escape reserved words' do
      'foo'.to_ident.should == 'foo'
      'assert'.to_ident.should == 'assert_'
      'transient'.to_ident.should == 'transient_'
    end
  end

  describe 'The JavaScript language' do
      
    before(:each) { Cog.activate_language 'javascript' }
      
    it 'should map each primitive to an identifier' do
      :boolean.to_prim.should == 'Boolean'
      :integer.to_prim.should == 'Number'
      :long.to_prim.should == 'Number'
      :float.to_prim.should == 'Number'
      :double.to_prim.should == 'Number'
      :char.to_prim.should == 'String'
      :string.to_prim.should == 'String'
      :null.to_prim.should == 'Object'
    end

    it 'should map ruby objects to literals' do
      1.to_lit.should == '1'
      (2**31 - 1).to_lit.should == '2147483647'
      (2**31).to_lit.should == '2147483648'
      true.to_lit.should == 'true'
      false.to_lit.should == 'false'
      1.0.to_lit.should == '1.0'
      'c'.to_lit.should == '"c"'
      'fresh'.to_lit.should == '"fresh"'
      nil.to_lit.should == 'null'
    end

    it 'should escape reserved words' do
      'foo'.to_ident.should == 'foo'
      'Math'.to_ident.should == 'Math_'
      'var'.to_ident.should == 'var_'
    end
  end

  describe 'The Objective-C language' do
      
    before(:each) { Cog.activate_language 'objc' }
      
    it 'should map each primitive to an identifier' do
      :boolean.to_prim.should == 'BOOL'
      :integer.to_prim.should == 'int'
      :long.to_prim.should == 'long'
      :float.to_prim.should == 'float'
      :double.to_prim.should == 'double'
      :char.to_prim.should == 'char'
      :string.to_prim.should == 'NSString *'
      :null.to_prim.should == 'id'
    end

    it 'should map ruby objects to literals' do
      1.to_lit.should == '1'
      (2**15 - 1).to_lit.should == '32767'
      (2**15).to_lit.should == '32768l'
      true.to_lit.should == 'YES'
      false.to_lit.should == 'NO'
      1.0.to_lit.should == '1.0f'
      'c'.to_lit.should == '\'c\''
      'fresh'.to_lit.should == '@"fresh"'
      nil.to_lit.should == 'nil'
    end

    it 'should escape reserved words' do
      'foo'.to_ident.should == 'foo'
      '@class'.to_ident.should == '@class_'
      'retain'.to_ident.should == 'retain_'
    end
  end

  describe 'The Python language' do
      
    before(:each) { Cog.activate_language 'python' }
      
    it 'should map each primitive to an identifier' do
      :boolean.to_prim.should == 'bool'
      :integer.to_prim.should == 'int'
      :long.to_prim.should == 'int'
      :float.to_prim.should == 'float'
      :double.to_prim.should == 'float'
      :char.to_prim.should == 'str'
      :string.to_prim.should == 'str'
      :null.to_prim.should == 'object'
    end

    it 'should map ruby objects to literals' do
      1.to_lit.should == '1'
      (2**15 - 1).to_lit.should == '32767'
      (2**15).to_lit.should == '32768'
      true.to_lit.should == 'True'
      false.to_lit.should == 'False'
      1.0.to_lit.should == '1.0'
      'c'.to_lit.should == '"c"'
      'fresh'.to_lit.should == '"fresh"'
      nil.to_lit.should == 'None'
    end

    it 'should escape reserved words' do
      'foo'.to_ident.should == 'foo'
      'None'.to_ident.should == 'None_'
      'class'.to_ident.should == 'class_'
    end
  end

  describe 'The Ruby language' do
      
    before(:each) { Cog.activate_language 'ruby' }
      
    it 'should map each primitive to an identifier' do
      :boolean.to_prim.should == '!!'
      :integer.to_prim.should == 'Fixnum'
      :long.to_prim.should == 'Fixnum'
      :float.to_prim.should == 'Float'
      :double.to_prim.should == 'Float'
      :char.to_prim.should == 'String'
      :string.to_prim.should == 'String'
      :null.to_prim.should == 'Object'
    end

    it 'should map ruby objects to literals' do
      1.to_lit.should == '1'
      (2**15 - 1).to_lit.should == '32767'
      (2**15).to_lit.should == '32768'
      true.to_lit.should == 'true'
      false.to_lit.should == 'false'
      1.0.to_lit.should == '1.0'
      'c'.to_lit.should == '"c"'
      'fresh'.to_lit.should == '"fresh"'
      nil.to_lit.should == 'nil'
    end

    it 'should escape reserved words' do
      'foo'.to_ident.should == 'foo'
      '__FILE__'.to_ident.should == '__FILE___'
      'unless'.to_ident.should == 'unless_'
    end
  end
  
end
