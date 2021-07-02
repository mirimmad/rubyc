require_relative "scanner.rb"
s = """23 + 33 * 5 - 8 /
3"""
ss = Scanner.new(s)
ss.scanTokens.each do |x|
  puts x
end