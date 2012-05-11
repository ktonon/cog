module Stamp
  
  # When the Stampfile is processed, +self+ will be set to an instance of this
  # object at the global context.
  class Config
    attr_reader :path
    
    # Create an empty config object
    #
    # === Arguments
    # * +path+ - The path to the +Stampfile+ which will be used to configure
    #   this object.
    def initialize(path)
      @path = path
    end

  end
  
end
