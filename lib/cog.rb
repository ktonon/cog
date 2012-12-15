require 'cog/config'
require 'cog/controllers'
require 'cog/embeds'
require 'cog/errors'
require 'cog/generator'
require 'cog/helpers'
require 'cog/languages'
require 'cog/tool'
require 'cog/version'

# This top level module serves as a singleton instance of the {Config} interface.
module Cog

  extend Config
  
  # Prepare the project in the present working directory for use with +cog+
  # @return [nil]
  def self.initialize_project
    Generator.copy_file_if_missing File.join(Cog.gem_dir, 'Default.cogfile'), 'Cogfile'
    Cog.prepare :force_reset => true
    nil
  end

end
