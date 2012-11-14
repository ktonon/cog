module Cog
  module Generator
    
    # Methods for working with files
    module FileMethods
      
      # Get the template with the given name
      # @param path [String] path to template file relative one of the {Config#template_paths}
      # @option opt [Boolean] :absolute (false) is the +path+ argument absolute?
      # @option opt [Boolean] :as_path (false) return the template as an ERB instance (+false+) or an absolute path to the file (+true+)
      # @return [ERB, String] an instance of {http://ruby-doc.org/stdlib-1.9.3/libdoc/erb/rdoc/ERB.html ERB} or an absolute path to the template
      def get_template(path, opt={})
        path = path.to_s
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
      
      # Copy a file from +src+ to +dest+, but only if +dest+ does not already exist.
      # @param src [String] where to copy from
      # @param dest [String] where to copy to
      # @option opt [Boolean] :quiet (false) suppress writing to STDOUT?
      # @return [nil]
      def copy_file_if_missing(src, dest, opt={})
        unless File.exists? dest
          touch_directory File.dirname(dest), opt
          FileUtils.cp src, dest
          STDOUT.write "Created #{dest.relative_to_project_root}\n".color(:green) unless opt[:quiet]
        end
      end

      # Recursively create directories in the given path if they are missing.
      # @param path [String] a file system path representing a directory
      # @option opt [Boolean] :quiet (false) suppress writing to STDOUT?
      # @return [nil]
      def touch_directory(path, opt={})
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
        touch_directory File.dirname(path), opt
        FileUtils.touch path
        STDOUT.write "Created #{path.relative_to_project_root}\n".color(:green) unless opt[:quiet]
        nil
      end

      # @param file1 [File] a file
      # @param file2 [File] another file
      # @return [Boolean] whether or not the two files have the same content
      def files_are_same?(file1, file2)
        File.exists?(file1) && File.exists?(file2) && File.read(file1) == File.read(file2)
      end

    end
  end
end