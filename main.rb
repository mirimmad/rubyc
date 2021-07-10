require_relative "scanner.rb"
require_relative "parser.rb"
require_relative "gen.rb"
require_relative "sym.rb"

s = File.read("input02.txt")
ss = Scanner.new(s)
#ss.scanTokens.each do |x|
 # puts x
#end

sym = GlobalSymTab.new
p = Parser.new(ss.scanTokens, sym)
#puts 
x = p.parse

output = nil
begin
  output = File.open("out.s", "w")
rescue Exception
  puts "failed to open file"
  exit(1)
end

g = Gen.new(x, output, sym)
g.genCode




#puts x.right.a_type
#puts interpreter(x)