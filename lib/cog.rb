require 'cog/cogfile'
require 'cog/has_template'

module Cog
  
  # Loads the +Cogfile+ for the current project.
  # 
  # The +Cogfile+ will be looked for in the present working directory. If none
  # is found there the parent directory will be checked, and then the
  # grandparent, and so on.
  # 
  # === Returns
  # An instance of Config which has been configured with a Cogfile. Or +nil+ if
  # no +Cogfile+ could be found.
  def self.load_cogfile
    parts = Dir.pwd.split File::SEPARATOR
    i = parts.length
    while i >= 0 && !File.exists?(File.join(parts.slice(0, i) + ['Cogfile']))
      i -= 1
    end
    path = File.join(parts.slice(0, i) + ['Cogfile']) if i >= 0
    if path
      Cogfile.instance.instance_eval do
        @cogfile_path = path
        @project_root = File.dirname path
      end
      begin
        b = Cogfile.instance.instance_eval {binding}
        eval File.read(path), b
      rescue Exception => e
        raise CogfileError.new(e.to_s)
      end
      Cogfile.instance
    end
  end
  
end
