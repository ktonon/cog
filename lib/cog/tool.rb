require 'cog/tool/dsl'
require 'cog/errors'

module Cog

  class Tool
      
    # @return [String] name of the tool
    attr_reader :name

    # @return [String] explicit path to the tool
    attr_reader :path
      
    # @return [String] directory in which to find tool templates
    attr_reader :templates_path
      
    # @return [Boolean] the tool needs to be explicitly required
    attr_reader :explicit_require

    # @api developer
    # @return [GeneratorStamper] 
    attr_reader :generator_stamper
      
    # @param path [String] path to the <tt>cog_tool.rb</tt> file
    # @option opt [Boolean] :built_in (false) if +true+, {#templates_path} will be +nil+ for this tool, as the templates should be included with +cog+
    # @option opt [Boolean] :explicit_require (false) the tool needs to be explicitly required
    def initialize(path, opt={})
      unless File.basename(path) == 'cog_tool.rb' && File.exists?(path)
        raise Errors::InvalidToolConfiguration.new(path)
      end
      dir = File.dirname(path)
      @name = File.basename dir
      @path = File.expand_path File.join(dir, '..', "#{@name}.rb")
      @explicit_require = opt[:explicit_require]
      unless opt[:built_in]
        @templates_path = File.expand_path File.join(dir, '..', '..', 'cog', 'templates')
      end
    end
      
    # Fully load the tool
    def load
      require @path
    end

    # Stamp the generator
    # @param name [String] name of the generator to stamp
    # @param dest [String] file system path where the file will be created
    # @return [nil]
    def stamp_generator(name, dest)
      raise Errors::ToolMissingDefinition.new('stamp_generator') if @stamp_generator_block.nil?
      @stamp_generator_block.call name.to_s, dest.to_s
      nil
    end

    # Sort tools by name
    def <=>(other)
      @name <=> other.name
    end
  end

end
