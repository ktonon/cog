module Cog
  
  # Generators files are executed as instances of this type.
  class GeneratorSandbox
    
    include Generator
    
    def initialize(path)
      @path = path
    end
    
    def interpret
      eval File.read(@path), binding
      nil
    end
    
    def self.autoload_plugin(name, path)
      autoload name, path
    end
    
  end
end