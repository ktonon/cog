require 'cog'
include Cog::Generator

embed('contextual') do |c|
  ["hook is #{c.hook}",
   "filename is #{c.filename}",
   "lineno is #{c.lineno}",
   "body was #{c.body}",
   "extension is #{c.extension}",
   comment("this is a comment"), # active language is set
   c.args.join('-'),
   "contextual #{c.once? ? 'is' : 'is not'} once",
   "only occurrence #{(c.first? && c.last?) ? 'is' : 'is not'} first and last",
   "only occurrence index is #{c.index}",
   "only occurrence count is #{c.count}",
   ].join "\n"
end
