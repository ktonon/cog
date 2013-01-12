class Array
  
  # @api developer
  # Iterate through each path in this array
  # @yieldparam source [String] readable label for the source. In the case of plugins, the plugin name
  # @yieldparam source_type [Symbol] one of :built_in, :user, :plugin, or :project
  # @yieldparam path [String] a path to a cog resource, such as a template or generator
  # @return [Object] the return value of the block
  def each_with_cog_source(&block)
    each do |path|
      source, source_type = if plugin = path.relative_to_which_plugin?
        [plugin.name, :plugin]
      else
        path.cog_source_and_type
      end
      block.call source, source_type, path
    end
  end
end
