require 'cog/config'
require 'cog/generator'
require 'cog/mixins'
require 'cog/tool'
require 'cog/version'
require 'fileutils'

# The static methods on this top level module mirror the commands available to
# the +cog+ command line utility.
module Cog

  # Prepare the project in the present working directory for use with +cog+
  def self.initialize_project
    Object.new.instance_eval do
      class << self ; include Cog::Mixins::UsesTemplates ; end
      copy_if_missing File.join(Config.gem_dir, 'Default.cogfile'), 'Cogfile'
      config = Config.instance
      touch_path config.project_generators_path
      touch_path config.project_templates_path
    end
  end
  
end
