require 'cog/config'
require 'cog/meta'
require 'cog/mixins'
require 'cog/tool'
require 'fileutils'

# The static methods on this top level module mirror the commands available to
# the +cog+ command line utility.
module Cog
  
  def self.init
    copy_if_missing File.join(Config.gem_dir, 'Default.cogfile'), 'Cogfile'
    config = Config.for_project
    touch_path config.generator_dir
    touch_path config.template_dir
  end
  
  def self.tool(name)
    unless File.exists? name
      tool = Tool.new name
      tool.generate!
    else
      puts "Could not create tool for '#{name}', a file or directory already exists with that name"
    end
  end
  
  # Copy a file from +src+ to +dest+, but only if +dest+ does not already exist.
  def self.copy_if_missing(src, dest) # :nodoc:
    unless File.exists? dest
      FileUtils.cp src, dest
      puts "Created #{dest}"
    end
  end
  
  # Recursively create directories in the given path if they are missing.
  def self.touch_path(*path_components) # :nodoc:
    path = File.join path_components
    unless File.exists? path
      FileUtils.mkdir_p path
      puts "Created #{path}"
    end
  end
  
end
