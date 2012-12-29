module Cog

  # Describes a plugin found on the {Config#plugin_path}. The plugin {DSL::Cogfile} will have already been processed, and should have contained a call to {DSL::Cogfile#autoload_plugin}, which will make it's DSL available to generators via a {GeneratorSandbox}.
  class Plugin
      
    # @return [String] name of the plugin
    attr_reader :name

    # @return [String] path to the plugin directory
    attr_reader :path
    
    # @return [String] path to the plugin's cogfile
    attr_reader :cogfile_path
    
    # @return [Block] the block to use to stamp the generator
    attr_accessor :stamp_generator_block
    
    # @param cogfile_path [String] path to the plugin Cogfile
    def initialize(cogfile_path)
      unless File.exists?(cogfile_path)
        raise Errors::InvalidPluginConfiguration.new(cogfile_path)
      end
      @cogfile_path = File.expand_path cogfile_path
      @path = File.dirname @cogfile_path
      @name = File.basename @path
      @name = $1 if /^(.+?)\-(\d|\.)+(rc2)?$/ =~ @name
    end
    
    # Sort plugins by name
    def <=>(other)
      @name <=> other.name
    end
  end

end
