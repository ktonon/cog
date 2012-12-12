require 'cog'
include Cog::Generator

embed('contextual') do |c|
  ["filename is #{c.filename}",
   "lineno is #{c.lineno}",
   "body was #{c.body}",
   "extension is #{c.extension}",
   c.language.comment("this is a comment"),
   c.args.join('-'),
   "contextual #{c.once? ? 'is' : 'is not'} once",
   ].join "\n"
end
