@fruits = %w(apple orange pear).sort

stamp 'fruit-files.pro', 'fruit-files.pro'

embed 'fruit-files' do
  stamp 'fruit-files.pro'
end

embed 'include-fruits' do
  @fruits.collect {|f| "#include \"#{f}.h\""}.join "\n"
end
