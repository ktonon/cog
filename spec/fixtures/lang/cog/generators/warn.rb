require 'fileutils'

Cog.language_extensions.each do |ext|
  tp = Cog.project_template_path
  FileUtils.cp File.join(tp, 'warn.erb'), File.join(tp, "warn.#{ext}.erb")
  stamp "warn.#{ext}", "generated_warn.#{ext}"
end
