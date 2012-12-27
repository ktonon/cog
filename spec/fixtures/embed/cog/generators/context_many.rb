embed('context-many') do |c|
  ["#{c.index} of #{c.count} on line #{c.lineno}",
   "#{c.first? ? 'is' : 'is not'} first",
   (c.first? != c.last?) ? 'but' : 'and',
   "#{c.last? ? 'is' : 'is not'} last"].join " "
end
