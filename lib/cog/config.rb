require 'cog/config/cogfile'
require 'cog/config/lang_info'
require 'cog/languages'
require 'cog/errors'
require 'cog/tool'

module Cog
  
  # This is a low level interface. It is mainly used by the {Generator} methods to determine where to find things, and where to put them.
  # When +cog+ is used in a project it will be configured with a {Cogfile}. The Cogfile is processed during a call to {#prepare}.
  module Config
        
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
    
    # @return [Languages::Language] language which is active in the current context
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
    # * {#cog_templates_path} which is *always* present
    #
    # @return [Array<String>] a list of directories order with ascending priority
    def template_paths
      [@project_templates_path, active_tool && active_tool.templates_path, Cog.cog_templates_path].compact
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
        require File.join(Cog.gem_dir, 'lib', 'cog', 'built_in_tools', built_in.to_s, 'cog_tool.rb')
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
    # @param path [String] path to the <tt>cog_tool.rb</tt> file. This method should be called from the <tt>cog_tool.rb</tt> file, in which case <tt>__FILE__</tt> should be used as the argument
    # @option opt [Boolean] :built_in (false) if +true+, then treat this tool as a built-in tool. If you are defininig a custom tool, leave this value as +false+
    # @yield [Tool::DSL] define the tool
    # @return [nil]
    # @example
    #   require 'cog'
    #   include Cog::Generator
    # 
    #   Cog.register_tool __FILE__ do |tool|
    #
    #     # Define a method which creates the generator
    #     tool.stamp_generator do |name, dest|
    #
    #       # Setup context for the template
    #       @name = name
    #
    #       # Create the generator file
    #       stamp 'my_tool/generator.rb', dest, :absolute_destination => true
    #
    #     end
    #   end
    def register_tool(path, opt={}, &block)
      tool = Tool.new path, :built_in => opt[:built_in], :explicit_require => @next_tool_was_required_explicitly
      dsl = Tool::DSL.new tool
      block.call dsl
      @tools[tool.name] = tool
      nil
    end
    
    # @api developer
    # @return [Boolean] whether or not a tool is registered with the given name
    def tool_registered?(name)
      @tools.member? name
    end
    
    # Activate the registered tool with the given name within the scope of the provided block. If no block is provided, the tool will remain active indefinitely.
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
      throw :ActivateLanguageRequiresABlock if block.nil?
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
    
    # @param ext [String] the file extension
    # @return [Languages::Language, nil] the language for the given extension
    def language_for_extension(ext)
      ext = ext.to_s.downcase.to_sym
      lang_id = @language_extension_map[ext]
      Languages.get_language lang_id unless lang_id.nil?
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
    
    # Location of the built-in templates
    def cog_templates_path
      File.join Cog.gem_dir, 'templates'
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
