require 'cog/config'
require 'cog/has_template'

module Cog
  
  class CogfileError < StandardError
    def message
      "in Cogfile, " + super
    end
  end
  
  # Loads the +Cogfile+.
  # 
  # The +Cogfile+ will be looked for in the present working directory. If none
  # is found there the parent directory will be checked, and then the
  # grandparent, and so on.
  # 
  # === Returns
  # An instance of Config which has been configured using the +Cogfile+, if
  # one was found, otherwise +nil+.
  def self.load_cogfile
    parts = Dir.pwd.split File::SEPARATOR
    i = parts.length
    while i >= 0 && !File.exists?(File.join(parts.slice(0, i) + ['Cogfile']))
      i -= 1
    end
    path = File.join(parts.slice(0, i) + ['Cogfile']) if i >= 0
    if path
      cogfile = Config.new path
      begin
        b = cogfile.instance_eval {binding}
        eval File.read(path), b
      rescue Exception => e
        raise CogfileError.new(e.to_s)
      end
      cogfile
    end
  end
  
end
