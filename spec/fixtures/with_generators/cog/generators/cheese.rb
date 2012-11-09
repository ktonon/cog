require 'cog'

class Cheeses 
  include Cog::Generator
  
  def generate
    @cheeses = [:brie, :cheddar, :gruyere]
    stamp 'cheeses.txt', 'generated_cheeses.txt'
  end
end

Cheeses.new.generate
