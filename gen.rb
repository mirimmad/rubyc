
require_relative "cg.rb"

class Gen
  def initialize(node, output, sym)
    @node = node
    @cg = Cg.new(output)
    @sym = sym
    @nlabel = 0
  end

  #The kernel function
  def genCode()
    @cg.cgpreamble
    gen(@node)
  end

  #The traversal function
  def gen(node, reg=-1)
    case node
    when IntLit
      @cg.cgload(node.value.to_i)
    when Binary
      binary(node, false, -1)
    when Ident
      Ident(node)
    when LVIdent
      LVIdent(node, reg)
    when Statements
      for stmt in node.stmts
        gen(stmt)
      end
    when Compoundstatement
      for stmt in node.stmts
        gen(stmt)
      end
    when PrintStmt
      printStmt(node)
    when VarDecl
      varDecl(node)
    when AssignmentStmt
      assignmentStmt(node)
    when IfStmt
      ifStmt(node)
    when WhileStmt
      whileStmt(node)
    when FuncDecl
      funcDecl(node)
    end

  end
  
  
  #For handling binary AST
  def binary(node, iff, label)
    #iff = true if `binary` was called to evaluate the condition clause of an (if-statement or while-stmt)
    if node.left
      leftreg = gen(node.left)
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
    when :EQ_EQ, :NE, :LT, :GT, :GE, :LE
      if not iff
        @cg.cgcompare_and_set(node.a_type, leftreg, rightreg)
      else
        @cg.cgcompare_and_jump(node.a_type, leftreg, rightreg, label)
      end
    else
      puts "unknown AST op #{node.a_type}"
      exit(1)
    end
  end

  def Ident(node)
    @cg.cgloadglob(@sym.names[node.id])
  end

  def LVIdent(node, reg)
    @cg.cgstoreglob(reg, @sym.names[node.id])
  end

  def printStmt(node)
    reg = gen(node.expr)
    @cg.cgprintint(reg)
    @cg.freeall_registers()
  end

  def varDecl(node)
    code = @cg.cgglobsym(node.ident)
  end

  def funcDecl(node)
    @cg.cgfuncpreamble(node.name)
    gen(node.body)
    @cg.cgfuncpostamble
  end
  def assignmentStmt(node)
    #LVIdent is the right of the node
    #left is the exprssion which will "compile" into register that stores the result
    leftreg = gen(node.left)
    rightreg = gen(node.right, leftreg)
    @cg.free_register(leftreg)
    rightreg
  end

  def label
    @nlabel = @nlabel + 1
  end

  def ifStmt(node)
    lfalse = label
    lend = nil
    if(node.elseBranch != nil)
      lend = label
    end
    binary(node.cond, true, lfalse)
    @cg.freeall_registers

    gen(node.thenBranch)

    @cg.freeall_registers

    if(node.elseBranch != nil)
      @cg.cgjmp(lend)
    end

    @cg.cglabel(lfalse)

    if(node.elseBranch != nil)
      gen(node.elseBranch)
      @cg.freeall_registers
      @cg.cglabel(lend)
    end
    -1
  end

  def whileStmt(node)
    lstart = label
    lend = label

    @cg.cglabel(lstart)
    binary(node.cond, true, lend)
    @cg.freeall_registers
    gen(node.body)
    @cg.freeall_registers

    @cg.cgjmp(lstart)
    @cg.cglabel(lend)
    -1
  end

end