require 'cog/config'

class String
  
  # @return [String] strips {Cog::Config#project_root} from the beginning of this string
  def relative_to_project_root
    return unless Cog::Config.instance.project?
    root = Cog::Config.instance.project_root
    start_with?(root) ? slice(root.length+1..-1) : dup
  end
end
