require 'cog'

class Cheese 
  include Cog::Generator
  
  def generate
    @cheeses = [:brie, :cheddar, :gruyere]
    stamp 'cheese.txt', 'generated_cheese.txt'
  end
end

Cheese.new.generate
