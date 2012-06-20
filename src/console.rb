require 'progress_bar'
require 'terminal-table'
require 'rainbow'

bar = ProgressBar.new
# bar = ProgressBar.new(100, :bar, :rate, :eta)
# bar - empty
# rate - ?
# counter - ile jeszcze
# percentage - procent
# elapsed ile minê³o

rows= []
rows <<  ['first file','15MB']
rows <<  ['second file','15MB']
rows << ['third','100MB']
table =  Terminal::Table.new :rows=>rows
100.times do
  sleep 0.1
  bar.increment!
end

puts "this is red".foreground(:red) + " and " + "this on yellow bg".background(:yellow) + " and " + "even bright underlined!".underline.bright