require_relative "scanner.rb"
s = "*-+"
ss = Scanner.new(s)
ss.scanTokens.each do |x|
  puts x
end