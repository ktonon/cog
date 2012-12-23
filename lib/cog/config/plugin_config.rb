module Cog
  module Config
    
    # {Config} methods related to plugins
    module PluginConfig
      
      # @return [Plugin] the active plugin affects the creation of new generators
      attr_reader :active_plugin
      
      # Activate the plugin with the given name
      # @return [nil]
      def activate_plugin(name)
        raise Errors::NoSuchPlugin.new name unless @plugins.member? name
        @active_plugin = @plugins[name]
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
          @plugins[p.name] = p
        end
        nil
      end

      # @api developer
      # @return [Boolean] whether or not a plugin is registered with the given name
      def plugin_registered?(name)
        @plugins.member? name
      end
    
      # Stamp the generator
      # @param name [String] name of the generator to stamp
      # @param dest [String] file system path where the file will be created
      # @return [nil]
      def stamp_generator(name, dest)
        raise Errors::PluginMissingDefinition.new('stamp_generator') if @stamp_generator_block.nil?
        @stamp_generator_block.call name.to_s, dest.to_s
        nil
      end
    
    end
  end
end
