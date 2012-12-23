module Cog

  # Contains controllers for managing basic +cog+ objects like generators, templates, and plugins
  module Controllers
    
    autoload :GeneratorController, 'cog/controllers/generator_controller'
    autoload :TemplateController, 'cog/controllers/template_controller'
    autoload :PluginController, 'cog/controllers/plugin_controller'

  end
end
