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

class Ident < Expression
  attr_reader :name, :id
  def initialize(name, id)
    @name = name
    @id = id
  end

  def to_s
    "Ident #{@name}(#{@id})"
  end
  def inspect
    to_s
  end
end

class LVIdent < Expression
  attr_reader :name, :id
  def initialize(name, id)
    @name = name
    @id = id
  end

  def to_s
    "LVIdent #{@name}(#{@id})"
  end
  def inspect
    to_s
  end
end

class Statements < Statement
  # a simple set of statements
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

class Compoundstatement < Statement
  # like `Statements` but enclosed by barces
  attr_reader :stmts
  def initialize(stmts)
    @stmts = stmts
  end
  def to_s
   puts "BLOCK"
    for s in stmts
      puts s.to_s
    end
    puts "BLOCK END"
    ''
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

class VarDecl < Statement
  attr_reader :ident, :id
  
  def initialize(ident, id)
    @ident = ident
    @id = id
  end

  def to_s
    "Var: #{@ident}"
  end

  def inspect
    to_s
  end
end

class AssignmentStmt < Statement
  attr_reader :left, :right
  
  def initialize(left, right)
    @left = left
    @right = right
  end

  def to_s
    "Assign: #{@left.to_s} = #{@right.to_s}"
  end
  def inspect
    to_s
  end
end

class IfStmt < Statement
  attr_reader :cond, :thenBranch, :elseBranch
  def initialize(cond, thenBranch, elseBranch)
    @cond = cond
    @thenBranch = thenBranch
    @elseBranch = elseBranch
  end

  def to_s
    puts "IF"
    puts "(" + @cond.to_s + ")"
    puts "THEN"
    puts @thenBranch.to_s
    if @elseBranch != nil
      puts "ELSE"
      puts @elseBranch.to_s
    end
  end

  def inspect
    to_s
  end
end