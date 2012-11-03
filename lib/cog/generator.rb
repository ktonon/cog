require 'cog/config'
require 'cog/errors'
require 'erb'

module Cog
  
  # Generators have the ability to #stamp templates into source code.
  #
  # This module defines a low-level interface for writing generators. To use it,
  # just include the Generator module in your class or object.
  module Generator

    # A list of available project generators
    def self.available
      [:dummy1, :dummy2]
    end

    # Get the template with the given name.
    #
    # ==== Parameters
    # * +path+ - a path to a template file which is relative to
    #   one of the template directories
    #
    # ==== Options
    # * <tt>:absolute</tt> - is the +path+ argument absolute? (default: +false+)
    #
    # ==== Returns
    # An instance of ERB.
    def get_template(path, opt={})
      path += '.erb'
      fullpath = if opt[:absolute]
        path
      else
        Config.instance.template_paths.inject('') do |found, prefix|
          x = File.join prefix, path
          found.empty? && File.exists?(x) ? x : found
        end
      end
      raise Errors::MissingTemplate.new fullpath unless File.exists? fullpath
      ERB.new File.read(fullpath), 0, '>'
    end
    
    # Stamp a template +source+ onto a +destination+.
    #
    # ==== Arguments
    # * +template_path+ - a path to a template file which is relative to one
    #   of the template directories
    # * +destination+ - a path to which the generated file should be written
    #
    # ==== Options
    # * <tt>:absolute_template_path</tt> - is the +template_path+ argument absolute? (default: +false+)
    def stamp(template_path, destination, opt={})
      t = get_template template_path, :absolute => opt[:absolute_template_path]
      b = opt[:binding] || binding
      FileUtils.mkpath File.dirname(destination) unless File.exists? destination
      scratch = "#{destination}.scratch"
      File.open(scratch, 'w') {|file| file.write t.result(b)}
      if same? destination, scratch
        FileUtils.rm scratch
      else
        puts "Generated #{destination}"
        FileUtils.mv scratch, destination
      end
      nil
    end

    # Copy a file from +src+ to +dest+, but only if +dest+ does not already exist.
    def copy_if_missing(src, dest)
      unless File.exists? dest
        FileUtils.cp src, dest
        puts "Created #{dest}"
      end
    end

    # Recursively create directories in the given path if they are missing.
    def touch_path(*path_components)
      path = File.join path_components
      unless File.exists? path
        FileUtils.mkdir_p path
        puts "Created #{path}"
      end
    end
    
    # File extension for a snippet of the given source code language.
    # ==== Example
    #   snippet_extension 'c++' # => 'h'
    def snippet_extension(lang = 'text')
      case lang
      when /(c\+\+|c|objc)/i
        'h'
      else
        'txt'
      end
    end
          
    # A warning that indicates a file is maintained by a generator
    def generated_warning
      lang = Config.instance.language
      t = get_template "snippets/#{lang}/generated_warning.#{snippet_extension lang}", :cog_template => true
      t.result(binding)
    end
    
    def include_guard_begin(name)
      full = "COG_INCLUDE_GUARD_#{name.upcase}"
      "#ifndef #{full}\n#define #{full}"
    end
    
    def include_guard_end
      "#endif // COG_INCLUDE_GUARD_[...]"
    end
    
    def namespace_begin(name)
      return if name.nil?
      case Config.instance.language
      when /c\+\+/
        "namespace #{name} {"
      end
    end

    def namespace_end(name)
      return if name.nil?
      case Config.instance.language
      when /c\+\+/
        "} // namespace #{name}"
      end
    end
    
  private
    def same?(original, scratch) # :nodoc:
      if File.exists? original
        File.read(original) == File.read(scratch)
      else
        false
      end
    end

  end
end
