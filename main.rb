require_relative "scanner.rb"
require_relative "parser.rb"
require_relative "gen.rb"


s = File.read("input02.txt")
ss = Scanner.new(s)
#ss.scanTokens.each do |x|
 # puts x
#end


p = Parser.new(ss.scanTokens)
puts x = p.parse

output = nil
begin
  output = File.open("out.s", "w")
rescue Exception
  puts "failed to open file"
  exit(1)
end

g = Gen.new(x, output)
g.genCode




#puts x.right.a_type
#puts interpreter(x)