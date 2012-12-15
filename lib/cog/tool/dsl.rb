module Cog
  class Tool
    
    # Domain-specific language for defining cog tools
    class DSL

      # @api developer
      # @param tool [Tool] the tool which is being defined
      def initialize(tool)
        @tool = tool
      end
      
      # Define a block to call when stamping a generator for this tool
      # @yieldparam name [String] name of the generator to stamp
      # @yieldparam dest [String] file system path where the file will be created
      # @yieldreturn [nil]
      # @return [nil]
      def stamp_generator(&block)
        @tool.instance_eval do
          @stamp_generator_block = block
        end
      end
      
    end
  end
end