require 'cog/config/cogfile'
require 'singleton'

module Cog
  
  # This is a low level interface. It is mainly used by the {Generator} methods
  # to determine where to find things, and where to put them. When +cog+ is used
  # in a project the values of the singleton {Config.instance} should be configured using
  # a {Cogfile}.
  class Config
        
    # @return [String] path to the project's {Cogfile}
    attr_reader :cogfile_path

    # @return [String] default language in which to generated application source code
    attr_reader :language
    
    # @return [String] directory in which to find project generators
    attr_reader :project_generators_path

    # @return [String] directory in which the project's {Cogfile} is found
    attr_reader :project_root
    
    # @return [String] directory to which project source code is generated
    attr_reader :project_source_path

    # @return [String] directory in which to find custom project templates
    attr_reader :project_templates_path
    
    # @return [Boolean] are we operating in the context of a project?
    def project?
      !@project_root.nil?
    end

    # @param value [String] a value which is set by the active tool
    attr_writer :tool_templates_path
    
    # @return [String] a value which is set by the active tool
    attr_accessor :tool_generator_template
    
    # A list of directories in which to find ERB template files
    # @return [Array<String>] a list of directories order with ascending priority
    def template_paths
      [@project_templates_path, @tool_templates_path, File.join(Config.gem_dir, 'templates')].compact
    end
    
    # Location of the installed cog gem
    # @return [String] path to the cog gem
    def self.gem_dir
      spec = Gem.loaded_specs['cog']
      if spec.nil?
        # The current __FILE__ is:
        #   ${COG_GEM_ROOT}/lib/cog/config.rb
        File.expand_path File.join(File.dirname(__FILE__), '..', '..')
      else
        spec.gem_dir
      end
    end
    
    # The singleton instance
    #
    # Initialized using the Cogfile for the current project, if any can be
    # found. If not, then {#project?} will be +false+ and all the +project_...+
    # attributes will be +nil+.
    #
    # The Cogfile will be looked for in the present working directory. If none
    # is found there the parent directory will be checked, and then the
    # grandparent, and so on.
    # 
    # @return [Config] the singleton Config instance
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
      @language = 'c++'
    end

  end
end
