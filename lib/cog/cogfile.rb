require 'singleton'

module Cog
  
  # When the +Cogfile+ is processed, +self+ will be the singleton instance of
  # this object.
  class Cogfile
    
    # Path to the master +Cogfile+.
    def self.master_cogfile_path
      File.join File.dirname($0), '../Master.cogfile'
    end

    # Path to the default +Cogfile+.
    def self.default_cogfile_path
      File.join File.dirname($0), '../templates/Default.cogfile'
    end
    
    # Loads the default +Cogfile+ for the current project.
    # 
    # The +Cogfile+ will be looked for in the present working directory. If none
    # is found there the parent directory will be checked, and then the
    # grandparent, and so on.
    # 
    # === Returns
    # An instance of Cogfile which has been configured with a +Cogfile+. If no
    # such file was found then +nil+.
    def self.for_project
      return @for_project if @for_project
      parts = Dir.pwd.split File::SEPARATOR
      i = parts.length
      while i >= 0 && !File.exists?(File.join(parts.slice(0, i) + ['Cogfile']))
        i -= 1
      end
      path = File.join(parts.slice(0, i) + ['Cogfile']) if i >= 0
      if path && File.exists?(path)
        @for_project = self.new path
      end
    end

    # Loads the master +Cogfile+.
    def self.master
      return @master if @master
      @master = self.new master_cogfile_path
    end

    # Initialize from a +Cogfile+ at the given path.
    def initialize(path)
      @cogfile_path = File.expand_path path
      @project_root = File.dirname @cogfile_path
      begin
        eval File.read(path), binding
      rescue Exception => e
        raise CogfileError.new(e.to_s)
      end
    end

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
    # project_root unless the option <tt>:absolute</tt> is passed.
    # 
    # Can be used as a getter or a setter (within the +Cogfile+).
    def template_dir(val=nil, opt={})
      get_or_set(:template_dir, val) do |val|
        if opt[:absolute]
          val
        else
          File.join project_root, val
        end
      end
    end
    
    # The directory in which application code can be found. This is where
    # generated code will go. Probably along side non-generated code. It is
    # relative to project_root unless the option <tt>:absolute</tt> is passed.
    # 
    # Can be used as a getter or a setter (within the +Cogfile+).
    def code_dir(val=nil, opt={})
      get_or_set(:code_dir, val) do |val|
        if opt[:absolute]
          val
        else
          File.join project_root, val
        end
      end
    end
  end

  # For wrapping errors which occur during the processing of a +Cogfile+.
  class CogfileError < StandardError
    def message
      "in Cogfile, " + super
    end
  end
    
end
