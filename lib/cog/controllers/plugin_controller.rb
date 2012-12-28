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
        raise Errors::DuplicatePlugin.new(name) unless Cog.plugin(name).nil?
        @cogfile_type = :plugin
        @prefix = ''
        @cog_version = Cog::VERSION
        @plugin_name = name.to_s.underscore
        @plugin_module = name.to_s.camelize
        prefix = Cog.project_plugin_path
        prefix = prefix ? "#{prefix}/" : ''
        opt = { :absolute_destination => true, :binding => binding }
        [
          ['Cogfile', 'Cogfile'],
          ['plugin/plugin.rb', "lib/#{@plugin_name}.rb"],
          ['plugin/generator.rb.erb', "templates/#{@plugin_name}/generator.rb.erb"],
        ].each do |tm, dest|
          Generator.stamp "cog/#{tm}", "#{prefix}#{@plugin_name}/#{dest}", opt
        end
        nil
      end

      # @return [Array<String>] a list of available plugins
      def self.list(opt={})
        cs = Helpers::CascadingSet.new
        Cog.plugins.each do |plugin|
          cs.add_plugin plugin
        end
        cs.to_a
      end

    end
  end
end
