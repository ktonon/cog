require 'cog/config'
require 'erb'

module Cog
  module Mixins
    
    # Mixin for classes that can use templates to generate code
    module UsesTemplates
      
      # Copy a file from +src+ to +dest+, but only if +dest+ does not already exist.
      def copy_if_missing(src, dest)
        unless File.exists? dest
          FileUtils.cp src, dest
          puts "Created #{dest}"
        end
      end

      # Stamp a template +source+ onto a +destination+.
      # ==== Arguments
      # * +source+ - Relative path to the source template
      # * +destination+ - Relative path to the destination
      # ==== Options
      # * <tt>:source_prefix</tt>
      # * <tt>:destination_prefix</tt>
      def stamp(source, destination, opt={})
        src = File.join [opt[:source_prefix], source.split('/')].flatten.compact
        dest = File.join [opt[:destination_prefix], destination.split('/')].flatten.compact
        t = get_template src, :absolute => true
        b = opt[:binding] || binding
        FileUtils.mkpath File.dirname(dest) unless File.exists? dest
        scratch = "#{dest}.scratch"
        File.open(scratch, 'w') {|file| file.write t.result(b)}
        unless same? dest, scratch
          puts "Generated #{dest}"
          FileUtils.mv scratch, dest
        else
          FileUtils.rm scratch
        end
        nil
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
      
      # Get the template with the given name.
      #
      # === Parameters
      # * +path+ - a path to a template file which is relative to
      #   Config#template_dir and does not include the +.erb+ extension.
      #
      # === Options
      # * <tt>:absolute</tt> - set to +true+ to indicate that path is absolute
      #   and should not be prefixed. Default value is +false+.
      #
      # === Returns
      # An instance of ERB.
      def get_template(path, opt={})
        path += '.erb'
        fullpath = if opt[:absolute]
          path
        else
          Config.for_project.template_dirs.inject('') do |found, prefix|
            x = File.join prefix, path
            found || (File.exists?(x) ? x : '')
          end
        end
        raise Errors::MissingTemplate.new fullpath unless File.exists? fullpath
        ERB.new File.read(fullpath), 0, '>'
      end
      
      # Stamp this object using the template at the given path.
      #
      # === Parameters
      # * +path+ - to the template which is relative to Config#template_dir and 
      #   does not include the +.erb+ extension.
      #
      # === Options
      # * <tt>:target</tt> - the destination path to the generated file which is
      #   relative to either Config#app_dir or Config#cog_dir, depending on the
      #   value of the <tt>:target_type</tt> option.
      # * <tt>:target_type</tt> - either <tt>:cog</tt> or <tt>:app</tt>.
      #   Determines what path to prefix to the <tt>:target</tt> option. The
      #   default value is <tt>:app</tt>
      # * <tt>:use_absolute_path</tt> - set to +true+ to indicate that path is
      #   absolute and should not be prefixed. Default value is +false+.
      # * <tt>:binding</tt> - specify an alternate binding to use when resolving
      #   the +ERB+ template. If none is provided +self.binding+ will be used.
      #
      # === Returns
      # +nil+ if generated to a file, otherwise returns the generated code as a
      # string.
      def _stamp(path, opt={})
        t = get_template path, :absolute => opt[:use_absolute_path]
        b = opt[:binding] || binding
        target = opt[:target]
        if target.nil?
          t.result(b)
        else
          target_type = opt[:target_type] || :app
          target = case target_type.to_s
          when /cog/i
            File.join Config.for_project.cog_dir, target
          when /app/i
            File.join Config.for_project.app_dir, target
          end
          FileUtils.mkpath File.dirname(target) unless File.exists? target
          scratch = case target_type.to_s
          when /cog/i
            File.join Config.for_project.cog_dir, "#{opt[:target]}.scratch"
          when /app/i
            File.join Config.for_project.app_dir, "#{opt[:target]}.scratch"
          end
          File.open(scratch, 'w') {|file| file.write t.result(b)}
          unless same? target, scratch
            puts "Generated #{target}"
            FileUtils.mv scratch, target
          else
            FileUtils.rm scratch
          end
          nil
        end
      end
            
      # A warning that indicates a file is maintained by a generator
      def generated_warning
        lang = Config.for_project.language
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
        case Config.for_project.language
        when /c\+\+/
          "namespace #{name} {"
        end
      end

      def namespace_end(name)
        return if name.nil?
        case Config.for_project.language
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
  
  module Errors
    # Indiciates an attempt to use a non-existant template.
    class MissingTemplate < Exception
      def message
        'could not find the template ' + super
      end
    end
  end
  
end
