# This is the seed generator

dog = Cog.seed 'Dog' do |s|
  
  s.in_scope 'Animals'
  
  s.constructor
  
  s.destructor
  
  s.virtual_public_feature :speak do |f|
    f.param :string, :text, :desc => 'What should he say?'
    f.return :string
  end
end

dog.stamp_class 'Dog', :language => 'c++'
