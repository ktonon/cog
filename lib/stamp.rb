require 'stamp/has_template'

module Stamp
  
  # Loads the +Stampfile+.
  # 
  # The +Stampfile+ will be looked for in the present working directory. If none
  # is found there the parent directory will be checked, and then the
  # grandparent, and so on.
  # 
  # === Returns
  # The path to the +Stampfile+ if one was found and +nil+ otherwise.
  def self.load_stampfile
    parts = Dir.pwd.split File::SEPARATOR
    i = parts.length
    while i >= 0 && !File.exists?(File.join(parts.slice(0, i) + ['Stampfile']))
      i -= 1
    end
    path = File.join(parts.slice(0, i) + ['Stampfile']) if i >= 0
    if path
      # TODO: load it
    end
    path
  end
  
end
