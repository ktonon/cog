require 'cog/config'
require 'singleton'

module Cog
  
  # When the +Cogfile+ is processed, +self+ will be the singleton instance of
  # this object.
  class Cogfile
    include Singleton

    def get_or_set(name, val, &block) # :nodoc:
      if val.nil?
        instance_variable_get "@#{name}"
      else
        val = block.call val unless block.nil?
        instance_variable_set "@#{name}", val
      end
    end
    
    # The directory in which the +Cogfile+ is found.
    attr_reader :project_root
    
    # The path to the +Cogfile+.
    attr_reader :cogfile_path
    
    # The directory in which to find ERB template files. This is relative to
    # project_root
    # 
    # Can be used as a getter or a setter (within the +Cogfile+).
    def template_dir(val=nil)
      get_or_set :template_dir, val do |val|
        File.join project_root, val
      end
    end
    
    # The directory in which application code can be found. This is where
    # generated code will go. Probably along side non-generated code. It is
    # relative to project_root
    # 
    # Can be used as a getter or a setter (within the +Cogfile+).
    def code_dir(val=nil)
      get_or_set :code_dir, val do |val|
        File.join project_root, val
      end
    end
    
    def to_s # :nodoc:
      "#{project_root} #{code_dir}"
    end
  end

  # For wrapping errors which occur during the processing of a +Cogfile+.
  class CogfileError < StandardError
    def message
      "in Cogfile, " + super
    end
  end
    
end
