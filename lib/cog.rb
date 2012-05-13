require 'cog/cogfile'
require 'cog/template_controller'
require 'cog/mixins'
require 'fileutils'

module Cog

  # Make a cogfile at the given destination path.
  def self.copy_default_cogfile(dest)
    puts "Generated #{dest}"
    FileUtils.cp Cogfile.default_cogfile_path, dest
  end

end
