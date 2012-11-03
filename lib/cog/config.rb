require 'cog/config/cogfile'
require 'singleton'

module Cog
  
  # This interface is intended for use within generators. Apps can customize
  # Instances of this type
  # can be configured via Cogfile files.
  class Config
        
    # Path to the project's +Cogfile+.
    attr_reader :cogfile_path

    # Default language in which to generated application source code
    attr_reader :language
    
    # Directory in which to find project generators
    attr_reader :project_generators_path

    # Directory in which the project's +Cogfile+ is found
    attr_reader :project_root
    
    # Directory to which project source code is generated
    attr_reader :project_source_path

    # Directory in which to find custom project templates
    attr_reader :project_templates_path
    
    # Are we operating in the context of a project?
    # That is, could a Cogfile be found?
    def project?
      !@project_root.nil?
    end
    
    # A list of directories in which to find ERB template files.
    # Priority should be given first to last.
    def template_paths
      [@project_templates_path, @tool_templates_path, File.join(Config.gem_dir, 'templates')].compact
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
    
    # The singleton instance.
    #
    # Initialized using the +Cogfile+ for the current project, if any can be
    # found. If not, then #project? will be +false+.
    #
    # The +Cogfile+ will be looked for in the present working directory. If none
    # is found there the parent directory will be checked, and then the
    # grandparent, and so on.
    # 
    # ==== Returns
    # An instance of Cogfile which has been configured with a +Cogfile+. If no
    # such file was found then +nil+.
    def self.instance
      return @instance if @instance
      @instance = self.new
      
      # Attempt to find a Cogfile
      parts = Dir.pwd.split File::SEPARATOR
      i = parts.length
      while i >= 0 && !File.exists?(File.join(parts.slice(0, i) + ['Cogfile']))
        i -= 1
      end
      path = File.join(parts.slice(0, i) + ['Cogfile']) if i >= 0
      if path && File.exists?(path)
        @instance.instance_eval do
          @cogfile_path = File.expand_path path
          @project_root = File.dirname @cogfile_path
          cogfile = Cogfile.new self
          cogfile.interpret
        end
      end
      
      @instance
    end

  private

    def initialize
      @project_root = nil
    end

  end
end
