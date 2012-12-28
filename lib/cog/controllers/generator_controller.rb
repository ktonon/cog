module Cog
  module Controllers
    
    # Manage a project's generators
    module GeneratorController
      
      # Create a new generator
      # @param name [String] the name to use for the new generator
      # @option opt [String] :plugin_name (nil) plugin to use
      # @return [Boolean] was the generator successfully created?
      def self.create(name, opt={})
        plugin = Cog.plugin(opt[:plugin_name])
        prefix = Cog.project_generator_path
        raise Errors::NoSuchPlugin.new(opt[:plugin_name]) if plugin.nil?
        raise Errors::PluginMissingDefinition.new('stamp_generator') if plugin.stamp_generator_block.nil?
        raise Errors::ActionRequiresProjectGeneratorPath.new('create generator') unless prefix
        dest = File.join prefix, "#{name}.rb"
        raise Errors::DuplicateGenerator.new(dest) if File.exists?(dest)
        plugin.stamp_generator_block.call name.to_s, dest
      end

      # List the available project generators
      # @return [Array<String>] a list of generators
      def self.list
        Helpers::CascadingSet.process_paths Cog.generator_path, :ext => 'rb'
      end

      # Run the generator with the given name
      # @param name [String] name of the generator to run
      # @return [nil]
      def self.run(name)
        Cog.generator_path.reverse.each do |root|
          path = File.join root, "#{name}.rb"
          if File.exists?(path)
            GeneratorSandbox.new(path).interpret
            return
          end
        end
        raise Errors::NoSuchGenerator.new(name)
      end
      
      # Run all generators
      # @return [nil]
      def self.run_all
        Cog.generator_path.each do |root|
          Dir.glob("#{root}/*.rb").each do |path|
            GeneratorSandbox.new(path).interpret
          end
        end
      end
    end
  end
end
