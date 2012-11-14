require 'cog/config/cogfile'
require 'cog/config/tool'
require 'cog/config/lang_info'
require 'cog/languages'
require 'cog/errors'

module Cog
  
  # This is a low level interface. It is mainly used by the {Generator} methods
  # to determine where to find things, and where to put them. When +cog+ is used
  # in a project the values of the singleton {Config.instance} should be configured using
  # a {Cogfile}.
  class Config
        
    # @return [String] path to the project's {Cogfile}
    attr_reader :cogfile_path

    # @return [String] directory in which to find project generators
    attr_reader :project_generators_path

    # @return [String] directory in which the project's {Cogfile} is found
    attr_reader :project_root
    
    # @return [String] directory to which project source code is generated
    attr_reader :project_source_path

    # @return [String] directory in which to find custom project templates
    attr_reader :project_templates_path
    
    # @return [Languages::Lanugage] target language which should be used when creating generators, and no language is explicitly specified
    attr_accessor :target_language
    
    # @return [String] the target language which is currently active
    def active_language
      @active_languages.last
    end
    
    # @return [Tool] the active tool affects the creation of new generators
    def active_tool
      @active_tools.last
    end
    
    # @return [Boolean] whether or not we operating in the context of a project
    def project?
      !@project_root.nil?
    end
    
    # A list of directories in which to find ERB template files
    #
    # Templates should be looked for in the following order as determined by the list returned from this method
    #
    # * {#project_templates_path} which is present if {#project?}
    # * {Tool#templates_path} for each registered tool (in no particular order)
    # * {Config.cog_templates_path} which is *always* present
    #
    # @return [Array<String>] a list of directories order with ascending priority
    def template_paths
      [@project_templates_path, active_tool && active_tool.templates_path, Config.cog_templates_path].compact
    end
    
    # @return [Array<Tool>] a sorted list of available tools
    def tools
      @tools.values.sort
    end
    
    # Register built-in and custom tools.
    # @api developer
    #
    # Custom tools are specified in the +COG_TOOLS+ environment variable.
    # @return [nil]
    def register_tools
      # Register built-in tools
      [:basic].each do |built_in|
        require File.join(Config.gem_dir, 'lib', 'cog', 'built_in_tools', built_in.to_s, 'cog_tool.rb')
      end
      # Register custom tools defined in COG_TOOLS
      (ENV['COG_TOOLS'] || '').split(':').each do |path|
        explicit = path.end_with? '.rb'
        @next_tool_was_required_explicitly = explicit
        path = "#{path}/cog_tool" unless explicit
        begin
          require path
        rescue LoadError
          raise Errors::CouldNotLoadTool.new path
        end
      end
      nil
    end

    # Define a new +cog+ tool
    # @api developer
    # @param path [String] path to the <tt>cog_tool.rb</tt> file
    # @option opt [Boolean] :built_in (false) if +true+, then treat this tool as a built-in tool
    # @yield [Tool] define the tool
    # @return [nil]
    def register_tool(path, opt={}, &block)
      tool = Tool.new path, :built_in => opt[:built_in], :explicit_require => @next_tool_was_required_explicitly
      block.call tool
      @tools[tool.name] = tool
      nil
    end
    
    # @api developer
    # @return [Boolean] whether or not a tool is registered with the given name
    def tool_registered?(name)
      @tools.member? name
    end
    
    # Activate the registered tool with the given name with the scope of the provided block.
    # If no block is provided, the tool will remain active indefinitely.
    # @param name [String] name of the registered tool to activate
    # @yield the tool will be active within this block
    # @return [nil]
    def activate_tool(name, &block)
      name = name.to_s
      raise Errors::NoSuchTool.new(name) unless tool_registered?(name)
      @tools[name].load
      @active_tools << @tools[name]
      if block
        block.call
        @active_tools.pop
      end
    end
    
    # Activate a given language within the scope of the provided block.
    # Either provide <tt>:id</tt> or <tt>:ext</tt> but not both. If the extension does not match any of the supported languages, the {#active_language} will not change, but the block will still be called.
    # @option opt [:String] :id (nil) the lanuage identifier. Type <tt>cog language list</tt> to see the possible values
    # @option opt [:String] :ext (nil) a file extension which will map to a language identifier. Type <tt>cog language map</tt> to see mapped extensions
    # @yield within this block the {#active_language} will be set to the desired value
    # @return [Object] the value returned by the block
    def activate_language(opt={}, &block)
      lang_id = if opt[:ext]
        ext = opt[:ext].to_s
        ext = ext.slice(1..-1) if ext.start_with?('.')
        @language_extension_map[ext.downcase.to_sym] unless ext.empty?
      else
        opt[:id]
      end
      if lang_id
        @active_languages << Languages.get_language(lang_id)
        r = block.call
        @active_languages.pop
        r
      else
        block.call
      end
    end
    
    # @return [Array<LangInfo>] current configuration of supported languages
    def language_summary
      summary = {}
      @language_extension_map.each_pair do |ext, lang_id|
        lang_id = Languages::ALIAS[lang_id] || lang_id
        summary[lang_id] ||= LangInfo.new(lang_id, Languages::REV_ALIAS[lang_id] || [])
        summary[lang_id].extensions << ext
      end
      summary.values.sort
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
    
    # Location of the built-in templates
    def self.cog_templates_path
      File.join Config.gem_dir, 'templates'
    end

    # @param cogfile_path [String] if provided the {Cogfile} at the given path
    #   is used to initialize this instance, and {#project?} will be +true+
    def initialize(cogfile_path = nil)
      @project_root = nil
      @tools = {}
      @active_tools = [] # active tool stack
      @target_language = Languages::Language.new
      @active_languages = [Languages::Language.new] # active language stack
      @language_extension_map = Languages::DEFAULT_LANGUAGE_EXTENSION_MAP
      if cogfile_path
        @cogfile_path = File.expand_path cogfile_path
        @project_root = File.dirname @cogfile_path
        cogfile = Cogfile.new self
        cogfile.interpret
      end
    end

    # Find or create the singleton {Config} instance.
    #
    # Initialized using the {Cogfile} for the current project, if any can be
    # found. If not, {#project?} will be +false+ and all the <tt>project_...</tt>
    # methods will return +nil+.
    #
    # The {Cogfile} will be looked for in the present working directory. If none
    # is found there the parent directory will be checked, and then the
    # grandparent, and so on.
    # 
    # @return [Config] the singleton instance
    def self.instance
      return @instance if @instance
      
      # Attempt to find a Cogfile
      parts = Dir.pwd.split File::SEPARATOR
      i = parts.length
      while i >= 0 && !File.exists?(File.join(parts.slice(0, i) + ['Cogfile']))
        i -= 1
      end
      path = File.join(parts.slice(0, i) + ['Cogfile']) if i >= 0
      
      if path && File.exists?(path)
        @instance = self.new path
      else
        @instance = self.new
      end
    end
    
    # Explicitly set the singleton Config instance.
    #
    # The singleton must not already be set.
    #
    # @param config [Config] the instance to set as the singleton
    # @return [nil]
    def self.instance=(config)
      throw :ConfigInstanceAlreadySet unless @instance.nil?
      @instance = config
    end

  end
end
