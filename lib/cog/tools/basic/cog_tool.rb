require 'cog'

# Register basic as a tool with cog
Cog::Config.instance.register_tool __FILE__, :built_in => true do |tool|

  # Define how new baisc generators are created
  #
  # When the block is executed, +self+ will be an instance of Cog::Config::Tool::GeneratorStamper
  tool.stamp_generator do
    template_dest = File.join config.project_templates_path, "#{name}.txt.erb"
    stamp 'basic/generator.rb', generator_dest, :absolute_destination => true
    stamp 'basic/template.txt.erb', template_dest, :absolute_destination => true
  end
  
end
