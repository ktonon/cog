class Array
  
  # Iterate through each path in this array
  # @yieldparam source [String] readable label for the source. In the case of plugins, the plugin name
  # @yieldparam source_type [Symbol] one of :built_in, :user, :plugin, or :project
  # @yieldparam path [String] a path to a cog resource, such as a template or generator
  # @return [Object] the return value of the block
  def each_with_cog_source(&block)
    each do |path|
      source, source_type = if plugin = path.relative_to_which_plugin?
        [plugin.name, :plugin]
      elsif path.start_with? Cog.gem_dir
        ['cog', :built_in]
      elsif path.start_with? Cog.user_dir
        [File.basename(ENV['HOME']), :user]
      elsif path.start_with? Cog.project_root
        [File.basename(Cog.project_root), :project]
      else
        ['unknown', :unknown]
      end
      block.call source, source_type, path
    end
  end
end
