module Cog
  module Controllers
    
    # Manage +cog+ plugins
    #
    # @see https://github.com/ktonon/cog#plugins Introduction to Plugins
    module PluginController

      # Generate a new project plugin with the given name
      # @param name [String] name of the plugin to create. Should not conflict with other plugin names
      # @return [nil]
      def self.create(name)
        raise Errors::ActionRequiresProject.new('create plugin') unless Cog.project?
        raise Errors::DuplicatePlugin.new(name) if Cog.plugin_registered?(name)
        @cogfile_type = :plugin
        @prefix = ''
        @cog_version = Cog::VERSION
        @plugin_name = name.to_s.underscore
        @plugin_module = name.to_s.camelize
        opt = { :absolute_destination => true, :binding => binding }
        Generator.stamp 'cog/Cogfile', "#{Cog.project_plugin_path}/#{@plugin_name}/Cogfile", opt
        Generator.stamp 'cog/plugin/plugin.rb', "#{Cog.project_plugin_path}/#{@plugin_name}/lib/#{@plugin_name}.rb", opt
        Generator.stamp 'cog/plugin/generator.rb.erb', "#{Cog.project_plugin_path}/#{@plugin_name}/templates/#{@plugin_name}/generator.rb.erb", opt
        nil
      end

      # @param opt [Boolean] :verbose (false) list full paths to plugins
      # @return [Array<String>] a list of available plugins
      def self.list(opt={})
        Cog.plugins.collect do |plugin|
          opt[:verbose] ? plugin.path : plugin.name
        end
      end

    end
  end
end
