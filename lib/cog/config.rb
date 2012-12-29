module Cog
  
  # This is a low level interface. It is mainly used by the {Generator} methods to determine where to find things, and where to put them.
  # When +cog+ is used in a project it will be configured with a {DSL::Cogfile}. The Cogfile is processed during a call to {#prepare}.
  module Config

    autoload :LanguageConfig, 'cog/config/language_config'
    autoload :ProjectConfig, 'cog/config/project_config'
    autoload :PluginConfig, 'cog/config/plugin_config'
    
    include ProjectConfig
    include LanguageConfig
    include PluginConfig

    # @return [Array<String>] directories in which to find generators
    attr_reader :generator_path

    # @return [Array<String>] directories in which to find templates
    attr_reader :template_path

    # @return [Array<String>] directories in which to find plugins
    attr_reader :plugin_path

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

    # @return [String,nil] if installed as a gem, return the parent directory of the gem's location
    def gems_root_dir
      x = gem_dir
      File.expand_path(File.join(x, '..')) unless File.exists?(File.join(x, 'Gemfile'))
    end

    # @return [String] Path to <tt>${HOME}/.cog</tt>
    def user_dir
      File.expand_path File.join(ENV['HOME'], '.cog')
    end
    
    # @return [String] Path to the current user's cogfile
    def user_cogfile
      File.join user_dir, 'Cogfile'
    end
    
    # @return [Boolean] when listing files, full paths should be shown
    def show_fullpaths?
      @fullpaths
    end
    
    # Must be called once before using cog.
    # In the context of a command-line invocation, this method will be called automatically. Outside of that context, for example in a unit test, it will have to be called manually.
    # @option opt [Boolean] :fullpaths (false) when listing files, full paths should be shown
    # @option opt [Boolean] :minimal (false) only load the built-in Cogfile
    # @option opt [String] :project_cogfile_path (nil) explicitly specify the location of the project {DSL::Cogfile}. If not provided, it will be searched for. If none can be found, {#project?} will be +false+
    def prepare(opt={})
      throw :ConfigInstanceAlreadyPrepared if @prepared && !opt[:force_reset]
      @prepared = true
      @fullpaths = opt[:fullpaths]
      @generator_path = []
      @template_path = []
      @plugin_path = []
      @project_path = nil
      @plugins = {}
      @target_language = Language.new
      @active_languages = [Language.new] # active language stack
      @language = {}
      @language_extension_map = {}
      
      process_cogfiles opt
      post_cogfile_processing
      build_language_extension_map
    end
    
    private
    
    # @option opt [Boolean] :minimal (false) only load the built-in Cogfile
    # @option opt [String] :project_cogfile_path (nil) project cogfile
    def process_cogfiles(opt={})
      @project_cogfile_path = opt[:project_cogfile_path] || find_default_cogfile
      if @project_cogfile_path
        @project_cogfile_path = File.expand_path @project_cogfile_path
        @project_root = File.dirname @project_cogfile_path
      end
      process_cogfile built_in_cogfile
      return if opt[:minimal]
      process_cogfile user_cogfile if File.exists? user_cogfile
      process_cogfile @project_cogfile_path, :plugin_path_only => true if @project_cogfile_path
      plugins.each do |plugin|
        process_cogfile plugin.cogfile_path, :plugin => plugin
      end
      process_cogfile @project_cogfile_path if @project_cogfile_path
    end
    
    # @param path [String] path to the cogfile
    # @option opt [Boolean] :plugin_path_only (false) only process +plugin_path+ calls in the given cogfile
    # @option opt [Boolean] :active_plugin (false) process the +stamp_generator+ call in the given cogfile
    # @option opt [Plugin] :plugin (nil) indicate that the cogfile is for the given plugin
    def process_cogfile(path, opt={})
      cogfile = DSL::Cogfile.new self, path, opt
      cogfile.interpret
    end
    
    def post_cogfile_processing
      @language.each_value do |lang|
        if lang.comment_style != lang.key
          other = @language[lang.comment_style]
          lang.apply_comment_style other
        end
      end
    end
    
    def build_language_extension_map
      @language.each_value do |lang|
        lang.extensions.each do |ext|
          @language_extension_map[ext] = lang.key unless @language_extension_map.member?(ext)
        end
      end
    end
    
    # The {DSL::Cogfile} will be looked for in the present working directory. If none
    # is found there the parent directory will be checked, and then the
    # grandparent, and so on.
    # 
    # @return [Config, nil] the singleton instance
    def find_default_cogfile
      parts = Dir.pwd.split File::SEPARATOR
      i = parts.length
      while i >= 0 && !File.exists?(File.join(parts.slice(0, i) + ['Cogfile']))
        i -= 1
      end
      path = File.join(parts.slice(0, i) + ['Cogfile']) if i >= 0
      (path && File.exists?(path)) ? path : nil
    end
    
    # @return [String] path to the built-in cogfile
    def built_in_cogfile
      File.join gem_dir, 'BuiltIn.cogfile'
    end
    
  end
end
