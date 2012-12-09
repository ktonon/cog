require 'cog'
include Cog::Generator

@fruits = %w(apple orange pear).sort

stamp 'fruit-files.pro', 'fruit-files.pro'

snippet 'fruit-files' do
  stamp 'fruit-files.pro'
end

snippet 'include-fruits' do
  @fruits.collect {|f| "#include \"#{f}.h\""}.join "\n"
end
