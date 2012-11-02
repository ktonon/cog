require 'rubygems'
require 'singleton'
require 'cog/cogfile'

module Cog
  
  # This interface is intended for use within generators. Instances of this type
  # are initialized via Cogfile files.
  class Config
        
    # Directory to which application source code is generated.
    attr_reader :app_dir

    # Path to the +Cogfile+.
    attr_reader :cogfile_path

    # Directory in which to find Ruby source files. These are files which
    # control exactly how the code is going to be generated.
    attr_reader :generator_dir

    # Default language in which to generated application source code.
    attr_reader :language
    
    # Directory in which the +Cogfile+ is found.
    attr_reader :project_root
    
    # Directory in which to find custom app template files. These templates
    # have the highest precendence of all template files.
    attr_reader :app_template_dir
    
    # A list of directories in which to find ERB template files.
    # Priority should be given first to last.
    def template_dirs
      [@app_template_dir, @tool_template_dir, File.join(Config.gem_dir, 'templates')].compact
    end
    
    # Tools should set this value.
    # This will be inserted into the template_dirs in between the cog built-in
    # templates and the app templates (as defined in the app Cogfile).
    attr_writer :tool_template_dir
    
    # Initialize from a +Cogfile+ at the given path.
    # ==== Arguments
    # * +path+ - A file system path to a +Cogfile+. The file must exists.
    def initialize(path)
      @cogfile_path = File.expand_path path
      @project_root = File.dirname @cogfile_path
      cogfile = Cogfile.new self
      cogfile.interpret
    end

    # The default configuration for the project.
    #
    # Initialized using the +Cogfile+ for the current project.
    # The +Cogfile+ will be looked for in the present working directory. If none
    # is found there the parent directory will be checked, and then the
    # grandparent, and so on.
    # 
    # ==== Returns
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

    # Location of the installed cog gem
    def self.gem_dir # :nodoc:
      spec = Gem.loaded_specs['cog']
      if spec.nil?
        # The current __FILE__ is:
        #   ${COG_GEM_ROOT}/lib/cog/config.rb
        File.expand_path File.join(File.dirname(__FILE__), '..', '..')
      else
        spec.gem_dir
      end
    end
    
  end
  
end
