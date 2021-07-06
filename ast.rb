class Node
end

class Expression < Node
end

class Statement < Node
end

class IntLit < Expression
  attr_reader :value
  def initialize(value)
    @value = value
  end
  def to_s
    "#{@value}"
  end
end


class Binary < Expression
  attr_reader :a_type, :left, :right
  def initialize(a_type, left, right)
    @a_type = a_type
    @left = left
    @right = right
  end

  def to_s
    "[#{@a_type} #{@left.to_s} #{@right.to_s}]"
  end

end

class Statements < Statement
  attr_reader :stmts
  def initialize(stmts)
    @stmts = stmts
  end
  def to_s
    for s in stmts
      puts s.to_s
    end
    ""
  end
  def inspect
    to_s
  end
end

class PrintStmt < Statement
  attr_reader :expr
  def initialize(expr)
    @expr = expr
  end

  def to_s
    "PRINT: " + @expr.to_s
  end
  def inspect
    to_s
  end
end