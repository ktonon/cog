$LOAD_PATH << File.join(File.dirname(__FILE__))
require 'cog'

# Custom cog plugin beef 
module Beef 
  
  # Root of the DSL
  # Feel free to rename this to something more appropriate
  def self.widget(generator_name, &block)
    w = Widget.new generator_name
    block.call w
    w.generate
    nil
  end

  # Root type of the DSL
  # You'll want to rename this to something more meaningful
  # and probably place it in a separate file.
  class Widget
    
    include Cog::Generator
    
    attr_accessor :context
    
    def initialize(generator_name)
      @generator_name = generator_name
    end
    
    def generate
      puts "TODO: write generator code for beef"
    end
  end
end
