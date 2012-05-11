require 'stamp/config'
require 'stamp/has_template'

module Stamp
  
  class StampfileError < StandardError
    def message
      "in Stampfile, " + super
    end
  end
  
  # Loads the +Stampfile+.
  # 
  # The +Stampfile+ will be looked for in the present working directory. If none
  # is found there the parent directory will be checked, and then the
  # grandparent, and so on.
  # 
  # === Returns
  # An instance of Config which has been configured using the +Stampfile+, if
  # one was found, otherwise +nil+.
  def self.load_stampfile
    parts = Dir.pwd.split File::SEPARATOR
    i = parts.length
    while i >= 0 && !File.exists?(File.join(parts.slice(0, i) + ['Stampfile']))
      i -= 1
    end
    path = File.join(parts.slice(0, i) + ['Stampfile']) if i >= 0
    if path
      stampfile = Config.new path
      begin
        b = stampfile.instance_eval {binding}
        eval File.read(path), b
      rescue Exception => e
        raise StampfileError.new(e.to_s)
      end
      stampfile
    end
  end
  
end
