require 'cog/config'
require 'cog/errors'
require 'cog/helpers'
require 'rainbow'

module Cog
  module Controllers
    
    # Manage a project's generators
    module GeneratorController
      
      # List the available project generators
      # @param verbose [Boolean] should full generator paths be listed?
      # @return [Array<String>] a list of generator names
      def self.list(verbose=false)
        raise Errors::ActionRequiresProject.new('list generators') unless Config.instance.project?
        x = Dir.glob(File.join Config.instance.project_generators_path, '*.rb')
        verbose ? x : (x.collect {|path| File.basename(path).slice(0..-4)})
      end

      # Create a new generator
      # @param name [String] the name to use for the new generator
      # @option opt [String] :tool ('basic') the name of the tool to use
      # @return [Boolean] was the generator successfully created?
      def self.create(name, opt={})
        raise Errors::ActionRequiresProject.new('create generator') unless Config.instance.project?

        gen_name = File.join Config.instance.project_generators_path, "#{name}.rb"
        if File.exists? gen_name
          STDERR.write "Generator '#{gen_name}' already exists\n".color(:red)
          return false
        end

        tool = (opt[:tool] || :basic).to_s
        template_name = File.join Config.instance.project_templates_path, "#{name}.txt.erb"
        if tool == 'basic' && File.exists?(template_name)
          STDERR.write "Template '#{template_name}' already exists\n".color(:red)
          return false
        end

        Object.new.instance_eval do
          extend Generator
          @name = name
          @class_name = name.to_s.camelize
          if tool == 'basic'
            stamp 'cog/generator/basic.rb', gen_name, :absolute_destination => true
            stamp 'cog/generator/basic-template.txt.erb', template_name, :absolute_destination => true
          else
            tool_path = Tool.find(tool)
            if tool_path.nil?
              STDERR.write "No such tool '#{tool}'"
              false
            else
              require tool_path
              @absolute_require = tool_path != tool
              @tool_parent_path = File.dirname(tool_path)
              stamp Config.instance.tool_generator_template, gen_name, :absolute_destination => true
              true
            end
          end
        end
      end

      # Run the generator with the given name
      # @param name [String] name of the generator as returned by {GeneratorController.list}
      # @option opt [Boolean] :verbose (false) in the case of an exception, should a full stack trace be written?
      # @return [Boolean] was the generator run successfully?
      def self.run(name, opt={})
        raise Errors::ActionRequiresProject.new('run generator') unless Config.instance.project?

        filename = File.join Config.instance.project_generators_path, "#{name}.rb"
        if File.exists? filename
          require filename
          return true
        end
        STDERR.write "No such generator '#{name}'\n".color(:red)
        false
      rescue => e
        trace = opt[:verbose] ? "\n#{e.backtrace.join "\n"}" : ''
        STDERR.write "Generator '#{name}' failed: #{e}#{trace}\n".color(:red)
        false
      end
      
    end
  end
end
