require 'cog/config'

class String
  
  # @return [String] strips {Cog::Config#project_root} from the beginning of this string
  def relative_to_project_root
    return dup unless Cog::Config.instance.project?
    relative_to Cog::Config.instance.project_root
  end
  
  # @param prefix [String] path prefix to strip from the beginning of this string
  # @return [String] this string as a file system path relative to the +prefix+
  def relative_to(prefix)
    return dup if prefix.nil?
    start_with?(prefix) ? slice(prefix.length+1..-1) : dup
  end
end
