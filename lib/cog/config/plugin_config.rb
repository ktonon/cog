module Cog
  module Config
    
    # {Config} methods related to plugins
    module PluginConfig
      
      # @return [Plugin] the plugin registered for the given name
      def plugin(name)
        @plugins[name]
      end
    
      # @return [Array<Plugin>] a sorted list of available plugins
      def plugins
        @plugins.values.sort
      end
    
      # @api developer
      # Register plugins found in the given directory
      # @param path [String] path to a directory containing cog plugins
      # @return [nil]
      def register_plugins(path)
        Dir.glob("#{path}/*/Cogfile").each do |cogfile_path|
          p = Plugin.new cogfile_path
          @plugins[p.name] ||= p
        end
        nil
      end

    end
  end
end
