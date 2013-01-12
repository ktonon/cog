class Symbol
  # @return [String] assuming this symbol represents a cog primitive type, returns an identifier of the mapped primitive in the {Cog::Config::LanguageConfig#active_language Cog.active_language}
  # @example
  #   # For Objective-C
  #   :boolean.to_prim # => 'BOOL'
  #
  #   # For Java
  #   :boolean.to_prim # => 'boolean'
  #
  #   # For C#
  #   :boolean.to_prim # => 'bool'
  def to_prim
    Cog.active_language.to_prim(self)
  end
end

# Helpers for {Bignum} and {Fixnum}
module Cognum
  # @return [String] literal representation in the {Cog::Config::LanguageConfig#active_language Cog.active_language}
  def to_lit
    Cog.active_language.to_integer(self) || Cog.active_language.to_long(self)
  end

  # @param bits [Fixnum] the size of a signed integer
  # @return [Boolean] whether or not this number can fit in a singed integer of the given size in the {Cog::Config::LanguageConfig#active_language Cog.active_language}
  def signed?(bits)
    limit = 2 ** (bits - 1)
    self >= -limit && self < limit
  end
end

class Bignum
  include Cognum
end

class Fixnum
  include Cognum
end

class Float
  # @return [String] literal representation in the {Cog::Config::LanguageConfig#active_language Cog.active_language}
  def to_lit
    Cog.active_language.to_float(self) || Cog.active_language.to_double(self)
  end
end

class String
  # @return [String] literal representation in the {Cog::Config::LanguageConfig#active_language Cog.active_language}
  # @example
  #   # For Objective-C
  #   "my cat walks over the keyboard".to_lit # => '@"my cat walks over the keyboard"'
  #
  #   # For Java
  #   "my cat walks over the keyboard".to_lit # => '"my cat walks over the keyboard"'
  def to_lit
    Cog.active_language.to_char(self) || Cog.active_language.to_string(self)
  end
  
  # @return [String] a safe identifier name in the {Cog::Config::LanguageConfig#active_language Cog.active_language} so as not to conflict with any {Cog::DSL::LanguageDSL#reserved reserved words}
  # @example
  #   # For Java
  #   "boolean".to_ident # => 'boolean_'
  #   "bool".to_ident    # => 'bool'
  #
  #   # For C#
  #   "boolean".to_ident # => 'boolean'
  #   "bool".to_ident    # => 'bool_'
  def to_ident
    Cog.active_language.to_ident(self)
  end
end

class TrueClass
  # @return [String] literal representation in the {Cog::Config::LanguageConfig#active_language Cog.active_language}
  # @example
  #   # For Objective-C
  #   true.to_lit # => 'YES'
  #
  #   # For Java
  #   true.to_lit # => 'true'
  def to_lit
    Cog.active_language.to_boolean(self)
  end
end

class FalseClass
  # @return [String] literal representation in the {Cog::Config::LanguageConfig#active_language Cog.active_language}
  # @example
  #   # For Objective-C
  #   false.to_lit # => 'NO'
  #
  #   # For Java
  #   false.to_lit # => 'false'
  def to_lit
    Cog.active_language.to_boolean(self)
  end
end

class NilClass
  # @return [String] literal representation in the {Cog::Config::LanguageConfig#active_language Cog.active_language}
  # @example
  #   # For C
  #   nil.to_lit # => 'NULL'
  #
  #   # For C#
  #   nil.to_lit # => 'null'
  def to_lit
    Cog.active_language.to_null(self)
  end
end

