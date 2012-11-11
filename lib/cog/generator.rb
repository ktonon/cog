require 'cog/config'
require 'cog/errors'
require 'cog/helpers'
require 'erb'
require 'rainbow'

module Cog
  
  # This module defines an interface which can be used by generator objects.
  # Specifically, it makes it easy to find ERB templates and render them into
  # generated source code files, using the {#stamp} method.
  #
  # @see https://github.com/ktonon/cog#generators Introduction to Generators
  module Generator

    # Get the template with the given name
    # @param path [String] path to template file relative one of the {Config#template_paths}
    # @option opt [Boolean] :absolute (false) is the +path+ argument absolute?
    # @option opt [Boolean] :as_path (false) return the template as an ERB instance (+false+) or an absolute path to the file (+true+)
    # @return [ERB, String] an instance of {http://ruby-doc.org/stdlib-1.9.3/libdoc/erb/rdoc/ERB.html ERB} or an absolute path to the template
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
      raise Errors::NoSuchTemplate.new path unless File.exists? fullpath
      if opt[:as_path]
        File.expand_path fullpath
      else
        ERB.new File.read(fullpath), 0, '>'
      end
    end
    
    # Stamp a template into a file or return it as a string
    # @param template_path [String] path to template file relative one of the {Config#template_paths}
    # @param destination [String] path to which the generated file should be written, relative to the {Config#project_source_path}
    # @option opt [Boolean] :absolute_template_path (false) is the +template_path+ absolute?
    # @option opt [Boolean] :absolute_destination (false) is the +destination+ absolute?
    # @option opt [Boolean] :quiet (false) suppress writing to STDOUT?
    # @return [nil or String] if +destination+ is not provided, the stamped template is returned as a string
    def stamp(template_path, destination=nil, opt={})
      t = get_template template_path, :absolute => opt[:absolute_template_path]
      b = opt[:binding] || binding
      return t.result(b) if destination.nil?
      
      dest = opt[:absolute_destination] ? destination : File.join(Config.instance.project_source_path, destination)
      FileUtils.mkpath File.dirname(dest) unless File.exists? dest
      scratch = "#{dest}.scratch"
      File.open(scratch, 'w') {|file| file.write t.result(b)}
      if same? dest, scratch
        FileUtils.rm scratch
      else
        updated = File.exists? dest
        FileUtils.mv scratch, dest
        STDOUT.write "#{updated ? :Updated : :Created} #{dest.relative_to_project_root}\n".color(updated ? :white : :green) unless opt[:quiet]
      end
      nil
    end

    # Copy a file from +src+ to +dest+, but only if +dest+ does not already exist.
    # @param src [String] where to copy from
    # @param dest [String] where to copy to
    # @option opt [Boolean] :quiet (false) suppress writing to STDOUT?
    # @return [nil]
    def copy_if_missing(src, dest, opt={})
      unless File.exists? dest
        touch_path File.dirname(dest), opt
        FileUtils.cp src, dest
        STDOUT.write "Created #{dest.relative_to_project_root}\n".color(:green) unless opt[:quiet]
      end
    end

    # Recursively create directories in the given path if they are missing.
    # @param path [String] a file system path representing a directory
    # @option opt [Boolean] :quiet (false) suppress writing to STDOUT?
    # @return [nil]
    def touch_path(path, opt={})
      unless File.exists? path
        FileUtils.mkdir_p path
        STDOUT.write "Created #{path.relative_to_project_root}\n".color(:green) unless opt[:quiet]
      end
      nil
    end
    
    # Create the file at the given path,
    # Creates directories along the path as required.
    # @param path [String] a file system path representing a file
    # @option opt [Boolean] :quiet (false) suppress writing to STDOUT?
    # @return [nil]
    def touch_file(path, opt={})
      touch_path File.dirname(path), opt
      FileUtils.touch path
      STDOUT.write "Created #{path.relative_to_project_root}\n".color(:green) unless opt[:quiet]
      nil
    end
    
    # File extension for a snippet of the given source code language.
    # @api unstable
    # @example
    #   snippet_extension 'c++' # => 'h'
    def snippet_extension(lang = 'text') # :nodoc:
      case lang
      when /(c\+\+|c|objc)/i
        'h'
      else
        'txt'
      end
    end

    # @api unstable
    def include_guard_begin(name)
      full = "COG_INCLUDE_GUARD_#{name.upcase}"
      "#ifndef #{full}\n#define #{full}"
    end
    
    # @api unstable
    def include_guard_end
      "#endif // COG_INCLUDE_GUARD_[...]"
    end
    
    # @api unstable
    def namespace_begin(name)
      return if name.nil?
      case Config.instance.language
      when /c\+\+/
        "namespace #{name} {"
      end
    end

    # @api unstable
    def namespace_end(name)
      return if name.nil?
      case Config.instance.language
      when /c\+\+/
        "} // namespace #{name}"
      end
    end
    
  private
    def same?(original, scratch)
      if File.exists? original
        File.read(original) == File.read(scratch)
      else
        false
      end
    end

  end
end
