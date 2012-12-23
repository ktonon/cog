module Cog
  module Controllers
    
    # Manage +cog+ plugins
    #
    # @see https://github.com/ktonon/cog#plugins Introduction to Plugins
    module PluginController

      # Generate a new plugin with the given name
      # @param name [String] name of the plugin to create. Should not conflict with other plugin names
      # @return [nil]
      def self.create(name)
        raise Errors::DestinationAlreadyExists.new(name) if File.exists?(name)
        raise Errors::DuplicatePlugin.new(name) if Cog.plugin_registered?(name)
        @plugin_name = name.to_s.downcase
        @plugin_module = name.to_s.capitalize
        @plugin_author = '<Your name goes here>'
        @plugin_email = 'youremail@...'
        @plugin_description = 'A one-liner'
        @cog_version = Cog::VERSION
        opt = { :absolute_destination => true, :binding => binding }
        Generator.stamp 'cog/custom_plugin/plugin.rb', "#{@plugin_name}/lib/#{@plugin_name}.rb", opt
        Generator.stamp 'cog/custom_plugin/cog_plugin.rb', "#{@plugin_name}/lib/#{@plugin_name}/cog_plugin.rb", opt
        Generator.stamp 'cog/custom_plugin/version.rb', "#{@plugin_name}/lib/#{@plugin_name}/version.rb", opt
        Generator.stamp 'cog/custom_plugin/generator.rb.erb', "#{@plugin_name}/cog/templates/#{@plugin_name}/generator.rb.erb", opt
        Generator.stamp 'cog/custom_plugin/template.txt.erb', "#{@plugin_name}/cog/templates/#{@plugin_name}/#{@plugin_name}.txt.erb", opt
        Generator.stamp 'cog/custom_plugin/Gemfile', "#{@plugin_name}/Gemfile", opt
        Generator.stamp 'cog/custom_plugin/Rakefile', "#{@plugin_name}/Rakefile", opt
        Generator.stamp 'cog/custom_plugin/plugin.gemspec', "#{@plugin_name}/#{@plugin_name}.gemspec", opt
        Generator.stamp 'cog/custom_plugin/LICENSE', "#{@plugin_name}/LICENSE", opt
        Generator.stamp 'cog/custom_plugin/README.markdown', "#{@plugin_name}/README.markdown", opt
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
