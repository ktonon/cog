module Cog
  
  # Generators files are executed as instances of this type.
  # Plugins make themselves available to generators via a call to {DSL::Cogfile#autoload_plugin}
  class GeneratorSandbox
    
    include Generator
    
    # @api developer
    # @param path [String] path to the generator ruby file
    def initialize(path)
      @path = path
    end
    
    # Interpret the generator ruby file as this instance
    # @api developer
    # @return [nil]
    def interpret
      eval File.read(@path), binding
      nil
    end
    
    # Register an autoload variable.
    # @api developer
    # @return [nil]
    def self.autoload_plugin(name, path)
      autoload name, path
      nil
    end
    
  end
end