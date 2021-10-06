
require_relative "cg.rb"
require_relative "label.rb"




class Gen
  def initialize(tree, output, sym)
    @tree = tree
    @cg = Cg.new(output, sym)
    #puts sym.names
    @sym = sym
    
  end

  #The kernel function
  def genCode()
    @cg.cgpreamble
    globalsymbols(@tree)
    gen(@tree)
  end

  #Var declarations need to be on top of the file. 
  def globalsymbols(node)
    case node
    when Statements
      for stmt in node.stmts
        if stmt.class == FuncDecl
          for stmt_ in stmt.body.stmts
            if stmt_.class == Statements
              for stmt__ in stmt_.stmts
                if stmt__.class == VarDecl
                  varDecl(stmt__)
                end
              end
            end
          end
        elsif stmt.class == Statements
          for stmt_ in stmt.stmts
            if stmt_.class == VarDecl
              varDecl(stmt_)
            end
          end
        end
        @cg.freeall_registers
      end
    end
  end
  #The traversal function
  def gen(node, reg=-1)
    case node
    when IntLit
      @cg.cgloadint(node.value.to_i, node.type)
    when Binary
      binary(node, false, -1)
    when Ident
      Ident(node)
    when LVIdent
      LVIdent(node, reg)
    when Scale
      Scale(node)
    when Statements
      for stmt in node.stmts
        gen(stmt)
        @cg.freeall_registers
      end   
    when PrintStmt
      printStmt(node)
    #when VarDecl
      #varDecl(node)
    when AssignmentStmt
      assignmentStmt(node)
    when IfStmt
      ifStmt(node)
    when WhileStmt
      whileStmt(node)
    when FuncDecl
      funcDecl(node)
    when FuncCall
      funcCall(node)
    when ReturnStmt
      returnStmt(node)
    when Addr
      addr(node)
    when Deref
      deref(node)
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
    @cg.cgloadglob(node.id)
  end

  def LVIdent(node, reg)
    @cg.cgstoreglob(reg, node.id)
  end

  def printStmt(node)
    reg = gen(node.expr)
    @cg.cgprintint(reg)
    @cg.freeall_registers()
  end

  def varDecl(node)
    code = @cg.cgglobsym(node.id)
  end

  def funcDecl(node)
    @cg.cgfuncpreamble(node.name)
    gen(node.body)
    @cg.cgfuncpostamble(node.nameslot)
  end

  def Scale(node)
    reg = gen(node.tree)
    case node.size
    when 2
      return @cg.cgshlconst(reg, 1)
    when 4
      return @cg.cgshlconst(reg, 2)
    when 8
      return @cg.cgshlconst(reg, 3)
    else
      reg_ = @cg.cgloadint(node.size, :P_INT)
      return @cg.cgmul(reg, reg_)
    end
  end
  def assignmentStmt(node)
    #LVIdent is the right of the node
    #left is the exprssion which will "compile" into register that stores the result
    leftreg = gen(node.left)
    rightreg = gen(node.right, leftreg)
    @cg.free_register(leftreg)
    rightreg
  end

  def self.label
    $nlabel = $nlabel + 1
  end

  def ifStmt(node)
    lfalse = Label::label
    lend = nil
    if(node.elseBranch != nil)
      lend = Label::label
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
    lstart = Label::label
    lend = Label::label

    @cg.cglabel(lstart)
    binary(node.cond, true, lend)
    @cg.freeall_registers
    gen(node.body)
    @cg.freeall_registers

    @cg.cgjmp(lstart)
    @cg.cglabel(lend)
    -1
  end

  def funcCall(node)
    reg = gen(node.args[0])
    @cg.cgcall(reg, node.id)
  end

  def returnStmt(node)
    reg = gen(node.expr)
    @cg.cgreturn(reg, node.functionId)
  end

  def addr(node)
    @cg.cgaddr(node.expr.id)
  end

  def deref(node)
    reg = gen(node.expr)
    @cg.cgderef(reg, node.expr.type)
  end
end