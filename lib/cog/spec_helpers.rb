require 'cog/spec_helpers/runner'
require 'cog/spec_helpers/matchers'

module Cog
  
  # Modules and classes to help write specs for testing +cog+
  #
  # === Example
  # Requiring the helpers will make extra SpecHelpers::Matchers available to
  # your RSpec tests. These are useful for testing a SpecHelpers::Invocation,
  # which is returned from a call to SpecHelpers::App#run
  #
  #   require 'cog/spec_helpers'
  # 
  #   describe 'The command line interface' do
  # 
  #     before :all do
  #       @cog = Cog::SpecHelpers::App.new 'bin/cog'
  #     end
  # 
  #     it 'should print help when no args are passed' do
  #       @cog.run.should show_help
  #     end
  # 
  #   end
  module SpecHelpers
  end
  
end
