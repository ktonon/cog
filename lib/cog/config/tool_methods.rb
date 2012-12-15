module Cog
  module Config
    
    # {Config} methods related to tools
    module ToolMethods
      
      # @return [Tool] the active tool affects the creation of new generators
      def active_tool
        @active_tools.last
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
      
    end
  end
end
