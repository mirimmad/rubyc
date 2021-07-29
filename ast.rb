class Node
end

class Expression < Node
end

class Statement < Node
end

class IntLit < Expression
  attr_reader :value
  attr_accessor :type
  def initialize(value, type)
    @value = value
    @type = type
  end
  def to_s
    "[#{@type}] #{@value}"
  end
end


class Binary < Expression
  attr_reader :a_type, :type, :left, :right
  def initialize(a_type, type, left, right)
    @a_type = a_type
    @left = left
    @right = right
    @type = type
  end

  def to_s
    "[#{@a_type} #{@left.to_s} #{@right.to_s}]"
  end

end

class Ident < Expression
  attr_reader :name, :id
  attr_accessor :type
  def initialize(name, id, type)
    @name = name
    @id = id
    @type = type
  end

  def to_s
    "Ident #{@name}(#{@type}, #{@id})"
  end
  def inspect
    to_s
  end
end

class LVIdent < Expression
  attr_reader :name, :id
  attr_accessor :type
  def initialize(name, id, type)
    @name = name
    @id = id
    @type = type
  end

  def to_s
    "LVIdent #{@name}(#{@type}, #{@id})"
  end
  def inspect
    to_s
  end
end

class FuncCall < Expression
  attr_accessor :type, :args, :id
  def initialize(type, args, id)
    @type = type
    @args = args
    @id = id
  end

  def to_s
    "Call to #{@id} with #{@args.map{|x|x.to_s}}"
  end

  def inspect
    to_s
  end
end

class Addr < Expression
  attr_accessor :type, :expr
  def initialize(type, expr)
    @type  = type
    @expr = expr
  end
  
  def to_s
    "ADDR [#{@type}]: #{@expr.to_s}"
  end

  def inspect
    to_s
  end
end

class Deref < Expression
  attr_accessor :type, :expr
  def initialize(type, expr)
    @type  = type
    @expr = expr
  end
  
  def to_s
    "DEREF [#{@type}]: #{@expr.to_s}"
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

=begin
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
=end

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

class FuncDecl < Statement
  attr_reader :name, :body, :nameslot
  def initialize(name, nameslot, body)
    @name = name
    @nameslot = nameslot
    @body = body
  end
  
  def to_s
    puts "FUNC #{@name}"
    puts body.to_s
    puts "F_END #{@name}"
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

class WhileStmt < Statement
  attr_reader :cond, :body

  def initialize(cond, body)
    @cond = cond
    @body = body
  end

  def to_s
    puts "WHILE:"
    puts @cond.to_s
    puts "BODY:"
    puts @body.to_s
    puts "WHILE_END"
  end

  def inspect
    to_s
  end
end

class ReturnStmt < Statement
  attr_reader :expr, :functionId

  def initialize(expr, functionId)
    @expr = expr
    @functionId = functionId
  end

  def to_s
    "RETURN " + @expr.to_s
  end

  def inspect
    to_s
  end
end