require 'cog/config'
require 'cog/errors'
require 'cog/helpers'
require 'rainbow'

module Cog
  module Controllers
    
    # Manage a project's generators
    module GeneratorController
      
      # Create a new generator
      # @param name [String] the name to use for the new generator
      # @return [Boolean] was the generator successfully created?
      def self.create(name)
        raise Errors::ActionRequiresProject.new('create generator') unless Config.instance.project?
        generator_dest = File.join Config.instance.project_generators_path, "#{name}.rb"
        raise Errors::DuplicateGenerator.new(generator_dest) if File.exists?(generator_dest)
        gs = Config.instance.active_tool.generator_stamper
        gs.stamp_generator name, generator_dest, Config.instance
      end

      # List the available project generators
      # @option opt [Boolean] :verbose (false) list full paths to generator files
      # @return [Array<String>] a list of generators
      def self.list(opt={})
        raise Errors::ActionRequiresProject.new('list generators') unless Config.instance.project?
        x = Dir.glob(File.join Config.instance.project_generators_path, '*.rb')
        opt[:verbose] ? x : (x.collect {|path| File.basename(path).slice(0..-4)})
      end

      # Run the generator with the given name
      # @param name [String] name of the generator as returned by {GeneratorController.list}
      # @return [nil]
      def self.run(name)
        raise Errors::ActionRequiresProject.new('run generator') unless Config.instance.project?
        path = File.join Config.instance.project_generators_path, "#{name}.rb"
        raise Errors::NoSuchGenerator.new(name) unless File.exists?(path)
        require path
        nil
      end
      
    end
  end
end