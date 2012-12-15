require 'cog/config'
require 'cog/errors'
require 'cog/generator'
require 'rainbow'

module Cog
  module Controllers
    
    # Manage +cog+ tools
    #
    # @see https://github.com/ktonon/cog#tools Introduction to Tools
    module ToolController

      # Generate a new tool with the given name
      # @param name [String] name of the tool to create. Should not conflict with other tool names
      # @return [nil]
      def self.create(name)
        raise Errors::DestinationAlreadyExists.new(name) if File.exists?(name)
        raise Errors::DuplicateTool.new(name) if Cog.tool_registered?(name)
        Object.new.instance_eval do
          extend Generator
          @tool_name = name.to_s.downcase
          @tool_module = name.to_s.capitalize
          @tool_author = '<Your name goes here>'
          @tool_email = 'youremail@...'
          @tool_description = 'A one-liner'
          @cog_version = Cog::VERSION
          stamp 'cog/custom_tool/tool.rb', "#{@tool_name}/lib/#{@tool_name}.rb", :absolute_destination => true
          stamp 'cog/custom_tool/cog_tool.rb', "#{@tool_name}/lib/#{@tool_name}/cog_tool.rb", :absolute_destination => true
          stamp 'cog/custom_tool/version.rb', "#{@tool_name}/lib/#{@tool_name}/version.rb", :absolute_destination => true
          stamp 'cog/custom_tool/generator.rb.erb', "#{@tool_name}/cog/templates/#{@tool_name}/generator.rb.erb", :absolute_destination => true
          stamp 'cog/custom_tool/template.txt.erb', "#{@tool_name}/cog/templates/#{@tool_name}/#{@tool_name}.txt.erb", :absolute_destination => true
          stamp 'cog/custom_tool/Gemfile', "#{@tool_name}/Gemfile", :absolute_destination => true
          stamp 'cog/custom_tool/Rakefile', "#{@tool_name}/Rakefile", :absolute_destination => true
          stamp 'cog/custom_tool/tool.gemspec', "#{@tool_name}/#{@tool_name}.gemspec", :absolute_destination => true
          stamp 'cog/custom_tool/LICENSE', "#{@tool_name}/LICENSE", :absolute_destination => true
          stamp 'cog/custom_tool/README.markdown', "#{@tool_name}/README.markdown", :absolute_destination => true
        end
        nil
      end

      # @param opt [Boolean] :verbose (false) list full paths to tools
      # @return [Array<String>] a list of available tools
      def self.list(opt={})
        Cog.tools.collect do |tool|
          opt[:verbose] ? tool.path : tool.name
        end
      end


    end
  end
end
