require 'cog'
include Cog::Generator

Cog.register_tool __FILE__, :built_in => true do |tool|

  tool.stamp_generator do |name, dest|
    @name = name
    stamp 'basic/generator.rb', dest, :absolute_destination => true
  end
  
end
