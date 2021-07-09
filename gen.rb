require_relative "cg.rb"

class Gen
  def initialize(node, output, sym)
    @node = node
    @cg = Cg.new(output)
    @sym = sym
  end

  #The kernel function
  def genCode()
    @cg.cgpreamble
    gen(@node, -1)
    @cg.cgpostamble
  end

  #The traversal function
  def gen(node, reg)
    case node
    when IntLit
      @cg.cgload(node.value.to_i)
    when Binary
      binary(node)
    when Statements
      for stmt in node.stmts
        gen(stmt, -1)
      end
    when PrintStmt
      printStmt(node)
    when VarDecl
      varDecl(node)
    when AssignmentStmt
      assignmentStmt(node)
    when Ident
      Ident(node)
    when LVIdent
      LVIdent(node, reg)
    end

  end
  
  
  #For handling binary AST
  def binary(node)
    if node.left
      leftreg = gen(node.left, -1)
    end

    if(node.right)
      rightreg = gen(node.right, leftreg)
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
    reg = gen(node.expr, -1)
    @cg.cgprintint(reg)
    @cg.freeall_registers()
  end

  def varDecl(node)
    code = @cg.cgglobsym(node.ident)
  end

  def assignmentStmt(node)
    #LVIdent is the right of the node
    #left is the exprssion which will "compile" into register that stores the result
    leftreg = gen(node.left, -1)
    rightreg = gen(node.right, leftreg)
    rightreg
  end

  def Ident(node)
    @cg.cgloadglob(@sym.names[node.id])
  end

  def LVIdent(node, reg)
    @cg.cgstoreglob(reg, @sym.names[node.id])
  end
  

end