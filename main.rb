require_relative "scanner.rb"
require_relative "parser.rb"

s = """2 + 3 * 5 - 8 /
3"""
ss = Scanner.new(s)
ss.scanTokens.each do |x|
  puts x
end


p = Parser.new(ss.scanTokens)
puts x = p.parse


def interpreter(node)
  case node
  when IntLit
    node.value.to_i
  when Binary
    left = interpreter(node.left)
    right = interpreter(node.right)
    op = node.a_type
    case op
    when :PLUS
      left + right
    when :MINUS
      left - right
    when :STAR
      left * right
    when :SLASH
      left / right
    end
  end
end
#puts x.right.a_type
#puts interpreter(x)