require 'cog/config'
require 'cog/controllers'
require 'cog/errors'
require 'cog/generator'
require 'cog/helpers'
require 'cog/languages'
require 'cog/project'
require 'cog/version'

# +cog+ is a command line utility that makes it a bit easier to organize a project
# which uses code generation. These are the API docs, but you might want to read
# the {https://github.com/ktonon/cog#readme general introduction} first.
module Cog

  # Prepare the project in the present working directory for use with +cog+
  # @return [nil]
  def self.initialize_project
    Object.new.instance_eval do
      class << self ; include Generator ; end
      copy_file_if_missing File.join(Config.gem_dir, 'Default.cogfile'), 'Cogfile'
      config = Config.instance
      touch_directory config.project_generators_path
      touch_directory config.project_templates_path
      nil
    end
  end

end
