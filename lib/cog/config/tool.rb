require 'cog/errors'
require 'cog/generator'

module Cog
  class Config

    class Tool
      
      # @return [String] name of the tool
      attr_reader :name

      # @return [String] explicit path to the tool
      attr_reader :path
      
      # @return [String] directory in which to find tool templates
      attr_reader :templates_path
      
      # @return [Boolean] the tool needs to be explicitly required
      attr_reader :explicit_require
      
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

      # Encapsulates the block which stamps the generator for this tool
      class GeneratorStamper
        
        include Generator
        
        # @return [Config] singleton instance
        attr_accessor :config
        
        # @return [String] path to the generator file which should be created
        attr_reader :generator_dest
        
        # @return [String] +underscore_version+ of the generator name
        attr_reader :name
        
        # @return [Tool] the tool for which this stamps generators
        attr_reader :tool
        
        # @return [String] +CamelizedVersion+ of the generator name
        def camelized
          @name.camelize
        end
        
        # @api developer
        # @param tool [Tool]
        # @param block [Block]
        def initialize(tool, block)
          @tool = tool
          @block = block
        end
        
        # Stamp the generator
        # @api developer
        def stamp_generator(name, generator_dest, config)
          @name = name.to_s.underscore
          @config = config
          @generator_dest = generator_dest
          instance_eval &@block
        end
      end
      
      # @api developer
      # @return [GeneratorStamper] 
      attr_reader :generator_stamper

      # Define a block to call when stamping a generator for this tool
      #
      # @yield The block should do the work of stamping the generator file, and any custom templates. The block's +self+ object will be a {GeneratorStamper}
      def stamp_generator(&block)
        @generator_stamper = GeneratorStamper.new self, block
      end
      
      # Sort tools by name
      def <=>(other)
        @name <=> other.name
      end
    end
  end
end
