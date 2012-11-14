require 'cog'

# Register basic as a tool with cog
Cog::Config.instance.register_tool __FILE__, :built_in => true do |tool|

  # Define how new baisc generators are created
  #
  # When the block is executed, +self+ will be an instance of Cog::Config::Tool::GeneratorStamper
  tool.stamp_generator do
    @language = Cog::Config.instance.target_language
    stamp 'basic/generator.rb', generator_dest, :absolute_destination => true
    @language.module_extensions.each do |ext|
      template_dest = File.join config.project_templates_path, "#{name}.#{ext}.erb"
      stamp "basic/template.#{ext}.erb", template_dest, :absolute_destination => true
    end
  end
  
end
