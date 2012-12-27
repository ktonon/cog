module Cog

  class Plugin
      
    # @return [String] name of the plugin
    attr_reader :name

    # @return [String] path to the plugin directory
    attr_reader :path
    
    # @return [String] path to the plugin's cogfile
    attr_reader :cogfile_path

    # @param cogfile_path [String] path to the plugin Cogfile
    def initialize(cogfile_path)
      unless File.exists?(cogfile_path)
        raise Errors::InvalidPluginConfiguration.new(cogfile_path)
      end
      @cogfile_path = File.expand_path cogfile_path
      @path = File.dirname @cogfile_path
      @name = File.basename @path
    end
      
    # Sort plugins by name
    def <=>(other)
      @name <=> other.name
    end
  end

end
