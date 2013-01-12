require 'active_support/core_ext'
require 'fileutils'
require 'rainbow'

require 'cog/errors'
require 'cog/native_extensions'
require 'cog/primitive'

# This top level module serves as a singleton instance of the {Config} interface. It is configured with various cogfiles, which are evaluated as instances of {DSL::Cogfile}.
module Cog

  autoload :Config, 'cog/config'
  autoload :Controllers, 'cog/controllers'
  autoload :DSL, 'cog/dsl'
  autoload :EmbedContext, 'cog/embed_context'
  autoload :Embeds, 'cog/embeds'
  autoload :Generator, 'cog/generator'
  autoload :GeneratorSandbox, 'cog/generator_sandbox'
  autoload :Helpers, 'cog/helpers'
  autoload :Language, 'cog/language'
  autoload :Plugin, 'cog/plugin'
  autoload :VERSION, 'cog/version'
  
  extend Config
  
  # Prepare the project in the present working directory for use with +cog+
  # @return [nil]
  def self.initialize_project
    @cogfile_type = :project
    @prefix = 'cog/'
    Generator.stamp 'cog/Cogfile', 'Cogfile', :absolute_destination => true, :binding => binding, :once => true
    
    @cogfile_type = :user
    @prefix = ''
    Generator.stamp 'cog/Cogfile', user_cogfile, :absolute_destination => true, :binding => binding, :once => true
    nil
  end

end
