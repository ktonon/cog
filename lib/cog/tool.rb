require 'cog/config'
require 'cog/generator'
require 'rainbow'

module Cog
  
  # For more details on writing tools see https://github.com/ktonon/cog#tools
  class Tool

    # A list of available tools
    def self.list(verbose=false)
      x = (ENV['COG_TOOLS'] || '').split ':'
      if x.all? {|path| File.exists?(path) && File.directory?(path)}
        if verbose
          x.collect {|path| File.expand_path path}
        else
          x.collect {|path| File.basename path}
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
          @author = '<Your name goes here>'
          @email = 'youremail@...'
          @description = 'A one-liner'
          @cog_version = Cog::VERSION
          stamp 'cog/tool/tool.rb', "#{@name}/lib/#{@name}.rb", :absolute_destination => true
          stamp 'cog/tool/version.rb', "#{@name}/lib/#{@name}/version.rb", :absolute_destination => true
          stamp 'cog/tool/generator.rb', "#{@name}/cog/templates/#{@name}/generator.rb.erb", :absolute_destination => true
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
  end

end