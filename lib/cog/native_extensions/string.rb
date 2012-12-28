class String
  
  # @return [String] strips {Cog::Config::ProjectMethods#project_root} from the beginning of this string
  def relative_to_project_root
    return dup unless Cog.project?
    relative_to Cog.project_root
  end
  
  # @param prefix [String] path prefix to strip from the beginning of this string
  # @return [String] this string as a file system path relative to the +prefix+
  def relative_to(prefix)
    return dup if prefix.nil?
    start_with?(prefix.to_s) ? slice(prefix.to_s.length+1..-1) : dup
  end

  # @return [Cog::Plugin,nil] if this string can be interpretted as a path relative to one of the registered cog plugins, return that plugin, otherwise return +nil+
  def relative_to_which_plugin?
    Cog.plugins.each do |plugin|
      return plugin if start_with?(plugin.path)
    end
    nil
  end
  
  # @param ext [String] file extension to remove from the end of this string
  # @return [String] a copy of this string with the given extension removed. Does nothing if this string does not edit with the extension
  def without_extension(ext)
    return dup if ext.nil?
    ext = ext.to_s
    ext = '.' + ext unless ext.start_with? '.'
    end_with?(ext) ? slice(0..(-ext.length - 1)) : dup
  end
  
  def cog_source_and_type
    if start_with? Cog.project_root
      [File.basename(Cog.project_root), :project]
    elsif start_with? Cog.user_dir
      [File.basename(ENV['HOME']), :user]
    elsif start_with? Cog.gem_dir
      ['cog', :built_in]
    else
      ['unknown', :unknown]
    end
  end
end
