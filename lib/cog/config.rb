require 'rubygems'
require 'singleton'

module Cog
  
  # When the +Cogfile+ is processed, +self+ will be the singleton instance of
  # this object.
  class Config
    
    # The directory in which the +Cogfile+ is found.
    attr_reader :project_root
    
    # The path to the +Cogfile+.
    attr_reader :cogfile_path
    
    # Loads the default +Cogfile+ for the current project.
    # 
    # The +Cogfile+ will be looked for in the present working directory. If none
    # is found there the parent directory will be checked, and then the
    # grandparent, and so on.
    # 
    # === Returns
    # An instance of Cogfile which has been configured with a +Cogfile+. If no
    # such file was found then +nil+.
    def self.for_project
      return @for_project if @for_project
      parts = Dir.pwd.split File::SEPARATOR
      i = parts.length
      while i >= 0 && !File.exists?(File.join(parts.slice(0, i) + ['Cogfile']))
        i -= 1
      end
      path = File.join(parts.slice(0, i) + ['Cogfile']) if i >= 0
      if path && File.exists?(path)
        @for_project = self.new path
      end
    end

    # Initialize from a +Cogfile+ at the given path.
    def initialize(path)
      @cogfile_path = File.expand_path path
      @project_root = File.dirname @cogfile_path
      begin
        eval File.read(path), binding
      rescue Exception => e
        raise CogfileError.new(e.to_s)
      end
    end

    # The directory in which to place Ruby generators and +ERB+ templates.
    #
    # Can be used as a getter, or a setter within the +Cogfile+. As a setter,
    # +val+ is relative to project_root unless the option <tt>:absolute</tt>
    # is truthy.
    def cog_dir(val=nil, opt={})
      get_or_set :cog_dir, val, opt
    end
    
    # The directory in which to place generated application code.
    #
    # Can be used as a getter, or a setter within the +Cogfile+. As a setter,
    # +val+ is relative to project_root unless the option <tt>:absolute</tt>
    # is truthy.
    def app_dir(val=nil, opt={})
      get_or_set :app_dir, val, opt
    end
    
    # The path to the routes file which maps defines how generators map to
    # generated application code.
    def routes_path
      File.join cog_dir, 'routes.rb'
    end

    # The directory in which to find Ruby source files. These are files which
    # control exactly how the code is going to be generated.
    def generator_dir(val=nil, opt={})
      File.join cog_dir, 'generators'
    end
    
    # The directory in which to find ERB template files.
    def template_dir(val=nil, opt={})
      File.join cog_dir, 'templates'
    end

    # Location of the installed gem
    def self.gem_dir
      spec = Gem.loaded_specs['cog']
      if spec.nil?
        File.expand_path File.join(File.dirname($0), '..')
      else
        spec.gem_dir
      end
    end

  private
    def get_or_set(name, val, opt={}, &block)
      if val.nil?
        instance_variable_get "@#{name}"
      else
        val = File.join project_root, val unless opt[:absolute]
        instance_variable_set "@#{name}", val
      end
    end
  end

  # For wrapping errors which occur during the processing of a +Cogfile+.
  class CogfileError < StandardError
    def message
      "in Cogfile, " + super
    end
  end
    
end
