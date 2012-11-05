require 'cog/config'
require 'cog/generator'
require 'rainbow'

module Cog
  
  # For more details on writing tools see https://github.com/ktonon/cog#tools
  class Tool

    # A list of available tools
    def self.list(verbose=false)
      x = (ENV['COG_TOOLS'] || '').split ':'
      if x.all? {|path| path.slice(-3..-1) != '.rb' || File.exists?(path)}
        if verbose
          x.collect {|path| path.slice(-3..-1) == '.rb' ? File.expand_path(path) : path}
        else
          x.collect {|path| path.slice(-3..-1) == '.rb' ? File.basename(path).slice(0..-4) : path}
        end
      else
        x.each do |path|
          if !File.exists? path
            STDERR.write "No such cog tool at path '#{path}'\n".color(:red)
          elsif !File.directory? path
            STDERR.write "Not a cog tool at path '#{path}'\n".color(:red)
          end
        end
        []
      end
    end
    
    # Generate a new tool with the given name
    #
    # ==== Returns
    # Whether or not the generator was created successfully
    def self.create(name)
      if File.exists? name
        STDERR.write "A #{File.directory?(name) ? :directory : :file} named '#{name}' already exists\n".color(:red)
        false
      else
        Object.new.instance_eval do
          extend Generator
          @name = name.to_s.downcase
          @module_name = name.to_s.capitalize
          @letter = name.to_s.slice(0,1).downcase
          @author = '<Your name goes here>'
          @email = 'youremail@...'
          @description = 'A one-liner'
          @cog_version = Cog::VERSION
          stamp 'cog/tool/tool.rb', "#{@name}/lib/#{@name}.rb", :absolute_destination => true
          stamp 'cog/tool/version.rb', "#{@name}/lib/#{@name}/version.rb", :absolute_destination => true
          stamp 'cog/tool/generator.rb.erb', "#{@name}/cog/templates/#{@name}/generator.rb.erb", :absolute_destination => true
          stamp 'cog/tool/template.txt.erb', "#{@name}/cog/templates/#{@name}/#{@name}.txt.erb", :absolute_destination => true
          stamp 'cog/tool/Gemfile', "#{@name}/Gemfile", :absolute_destination => true
          stamp 'cog/tool/Rakefile', "#{@name}/Rakefile", :absolute_destination => true
          stamp 'cog/tool/tool.gemspec', "#{@name}/#{@name}.gemspec", :absolute_destination => true
          stamp 'cog/tool/API.rdoc', "#{@name}/API.rdoc", :absolute_destination => true
          stamp 'cog/tool/LICENSE', "#{@name}/LICENSE", :absolute_destination => true
          stamp 'cog/tool/README.markdown', "#{@name}/README.markdown", :absolute_destination => true
        end
        true
      end
    end

    # Find an available tool with the given name
    #
    # ==== Returns
    # A fully qualified tool path, which can be required
    def self.find(name)
      x = (ENV['COG_TOOLS'] || '').split ':'
      x.each do |path|
        if path.slice(-3..-1) == '.rb'
          short = File.basename(path).slice(0..-4)
          return path if short == name
        else
          return path if path == name
        end
      end
    end

  end
end