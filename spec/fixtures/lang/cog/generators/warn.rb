require 'cog'

class Warn 
  include Cog::Generator
  
  def generate
    Cog::Languages::DEFAULT_LANGUAGE_EXTENSION_MAP.keys.each do |ext|
      stamp "warning", "generated_warn"
      stamp "warn.#{ext}", "generated_warn.#{ext}"
    end
  end
end

Warn.new.generate
