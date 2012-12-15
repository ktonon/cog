require 'cog/config/cogfile'
require 'cog/config/language_methods'
require 'cog/config/project_methods'
require 'cog/config/tool_methods'
require 'cog/languages'
require 'cog/errors'
require 'cog/tool'

module Cog
  
  # This is a low level interface. It is mainly used by the {Generator} methods to determine where to find things, and where to put them.
  # When +cog+ is used in a project it will be configured with a {Cogfile}. The Cogfile is processed during a call to {#prepare}.
  module Config
    include ProjectMethods
    include LanguageMethods
    include ToolMethods

    # @return [String] Location of the built-in templates
    def cog_templates_path
      File.join Cog.gem_dir, 'templates'
    end

    # @return [String] Location of the installed cog gem
    def gem_dir
      spec = Gem.loaded_specs['cog']
      if spec.nil?
        # The current __FILE__ is:
        #   ${COG_GEM_ROOT}/lib/cog/config.rb
        File.expand_path File.join(File.dirname(__FILE__), '..', '..')
      else
        spec.gem_dir
      end
    end
    
    # A list of directories in which to find ERB template files
    #
    # Templates should be looked for in the following order as determined by the list returned from this method
    #
    # * {#project_templates_path} which is present if {#project?}
    # * {Tool#templates_path} for each registered tool (in no particular order)
    # * {#cog_templates_path} which is *always* present
    #
    # @return [Array<String>] a list of directories order with ascending priority
    def template_paths
      [@project_templates_path, active_tool && active_tool.templates_path, Cog.cog_templates_path].compact
    end
 
    # Must be called once before using cog.
    # In the context of a command-line invocation, this method will be called automatically. Outside of that context, for example in a unit test, it will have to be called manually.
    # @option opt [String] :cogfile_path (nil) explicitly specify the location of the project {Cogfile}. If not provided, it will be searched for. If none can be found, {#project?} will be +false+
    # @option opt [Boolean] :force_reset (false) unless this is +true+, calling prepare a second time will fail
    def prepare(opt={})
      throw :ConfigInstanceAlreadyPrepared if @prepared && !opt[:force_reset]
      @prepared = true
      @cogfile_path = nil
      @project_root = nil
      @project_generators_path = nil
      @project_templates_path = nil
      @project_source_path = nil
      @tools = {}
      @active_tools = [] # active tool stack
      @target_language = Languages::Language.new
      @active_languages = [Languages::Language.new] # active language stack
      @language_extension_map = Languages::DEFAULT_LANGUAGE_EXTENSION_MAP
      opt[:cogfile_path] ||= find_default_cogfile
      if opt[:cogfile_path]
        @cogfile_path = File.expand_path opt[:cogfile_path]
        @project_root = File.dirname @cogfile_path
        cogfile = Cogfile.new self
        cogfile.interpret
      end
    end
    
    private
    
    # The {Cogfile} will be looked for in the present working directory. If none
    # is found there the parent directory will be checked, and then the
    # grandparent, and so on.
    # 
    # @return [Config] the singleton instance
    def find_default_cogfile
      parts = Dir.pwd.split File::SEPARATOR
      i = parts.length
      while i >= 0 && !File.exists?(File.join(parts.slice(0, i) + ['Cogfile']))
        i -= 1
      end
      path = File.join(parts.slice(0, i) + ['Cogfile']) if i >= 0
      (path && File.exists?(path)) ? path : nil
    end
  end
end
