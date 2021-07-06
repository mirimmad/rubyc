require_relative "cg.rb"

class Gen
  def initialize(node)
    @node = node
    begin
      output = File.open("out.s", "w")
    rescue Exception
      puts "Failed to open output file"
      exit(1)
    end
    @cg = Cg.new(output)
  end

  #The kernel function
  def genCode()
    @cg.cgpreamble
    gen(@node)
    @cg.cgpostamble
  end

  #The traversal function
  def gen(node)
    case node
    when IntLit
      @cg.cgload(node.value.to_i)
    when Binary
      binary(node)
    when Statements
      for stmt in node.stmts
        gen(stmt)
      end
    when PrintStmt
      printStmt(node)
    end
  end
  
  
  #For handling binary AST
  def binary(node)
    if node.left
      leftreg = gen(node.left)
    end

    if(node.right)
      rightreg = gen(node.right)
    end

    case node.a_type
    when :PLUS
      @cg.cgadd(leftreg, rightreg)
    when :MINUS
      @cg.cgsub(leftreg, rightreg)
    when :STAR
      @cg.cgmul(leftreg, rightreg)
    when :SLASH
      @cg.cgdiv(leftreg, rightreg)
    else
      puts "unknown AST op #{node.a_type}"
      exit(1)
    end
  end

  def printStmt(node)
    reg = gen(node.expr)
    @cg.cgprintint(reg)
    @cg.freeall_registers()
  end



end