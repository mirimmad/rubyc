
require_relative "ast.rb"
require_relative "sym.rb"
require_relative "types.rb"
require_relative "label.rb"


$opOprec = {
  :SLASH => 7,
  :STAR => 7,
  :PLUS => 6,
  :MINUS => 6,
  :GT => 4,
  :GE => 4,
  :LT => 4,
  :LE => 4,
  :EQ_EQ => 3,
  :NE => 3
}

class Parser
  def initialize(tokens, sym)
    @tokens = tokens
    @current = 0
    @token = nil
    @sym = sym
    @functionId = 0
  end

  def parse 
    advance
    statements
  end

  def statements
    list = []
    while 1
      list.push funcDecl
      if @token.type == :EOF
        break
      end
    end
    Statements.new(list)
  end

  def singleStmt
    case @token.type
    when :PRINT
       printStmt
    when :INT, :CHAR, :VOID, :LONG
      varDecl
    when :IDENT
      assignmentStmt
    when :IF
      ifStmt
    when :WHILE
      whileStmt
    when :FOR
      forStmt
    when :RETURN
      returnStmt
    else
      error(@token.line, "Syntax error", @token.type)
    end
  end

  def compoundStatement
    # single = true allows only one statement
    list = []
    match(:LBRACE, "{")
    while 1
     stmt = singleStmt
     if [PrintStmt, AssignmentStmt, FuncCall, ReturnStmt].include? stmt.class
      match(:SEMI, ";")
     end
     list.push stmt
     if @token.type == :RBRACE
      match(:RBRACE, "}")
      break
     end

    end
    Statements.new list
  end

  def funcDecl
    type = parseType(@token.type)
    line = @token.line
    #advance
    check(:IDENT)
    name = @token.literal
    endlabel = Label::label
    nameslot = @sym.addglob(@token.literal,type, :S_FUNCTION, endlabel)
    @functionId = nameslot
    advance
    match(:LPAREN, "(")
    match(:RPAREN, ")")
    body = compoundStatement
    if not type == :P_VOID
      if not body.stmts[-1].class == ReturnStmt
        error(line, "No return from a function with non-void type")
      end
    end
    FuncDecl.new(name, nameslot, body)
  end
  
  def parseType(type)
    tt = {:VOID => :P_VOID, :CHAR => :P_CHAR, :INT => :P_INT, :LONG => :P_LONG}
    t = if tt[type] != nil then tt[type] else error(@token.line, "Illegal type, token #{type}") end
      
    advance
    if @token.type == :STAR
      t = Types::pointerTo(t)
      advance
    end
    
    t
  end

  def varDecl
    type = parseType(@token.type)
    #advance
    check(:IDENT)
    id = @sym.addglob(@token.literal, type, :S_VARIABLE)
    ident = @token.literal
    advance
    match(:SEMI, ";")
    VarDecl.new(ident, id)
  end

  def returnStmt
    rType = @sym.names[@functionId]["type"] 
    if rType == :P_VOID
      error(@token.line, "Can't return from a void function")
    end
    match(:RETURN, "return")
    match(:LPAREN, "(")
    expr = binexp(0)
    comp = Types::compatibleTypes(expr.type, rType, true)
    case comp
    when :INCOMPATIBLE
      error(@token.line, "Incompatible types")
    when :WIDEN_LEFT
      expr.type = rType
    end
    match(:RPAREN, ")")
    ReturnStmt.new(expr, @functionId)
  end

  def assignmentStmt
    #left = the expression to be stored
    #right = the LVALUE where the expression is to be stored
    check(:IDENT)
    if peek.type == :LPAREN
      return funccall
    end
    if((id = @sym.findglob(@token.literal)) == -1)
      error(@token.line, "Undeclared variable", @token.literal)
    end
    advance
    right = LVIdent.new(@token.literal, id, @sym.names[id]["type"])
    match(:EQUALS, "=")

    left = binexp(0)
    comp = Types::compatibleTypes(left.type, right.type, true)
    case comp
    when :INCOMPATIBLE
      error(@token.line, "Incompatilbe types in assignment")
    when :WIDEN_LEFT
      left.type = right.type
    end
    t = AssignmentStmt.new(left, right)
    #match(:SEMI, ";")
    t
  end

  def ifStmt
    match(:IF, "if")
    match(:LPAREN, "(")

    cond = binexp(0)
    if not [:EQ_EQ, :NE, :LT, :LE, :GT, :GE].include? cond.a_type
      fatal("bad comparision operator.")
    end

    match(:RPAREN, ")")

    thenBranch = compoundStatement
    elseBranch = nil
    if(@token.type == :ELSE)
      advance
      elseBranch = compoundStatement
    end

    IfStmt.new(cond, thenBranch, elseBranch)

  end

  def whileStmt
    match(:WHILE, "while")
    match(:LPAREN, "(")
    cond = binexp(0)
    if not [:EQ_EQ, :NE, :LT, :LE, :GT, :GE].include? cond.a_type
      fatal("bad comparision operator.")
    end

    match(:RPAREN, ")")

    body = compoundStatement
    WhileStmt.new(cond,body)
  end

  def forStmt
    match(:FOR, "for")
    match(:LPAREN, "(")
    preop = singleStmt
    #puts preop, @token
    match(:SEMI, ";")
    cond = binexp(0)

    if not [:EQ_EQ, :NE, :LT, :LE, :GT, :GE].include? cond.a_type
      fatal("bad comparision operator.")
    end
    match(:SEMI, ")")
    postop = singleStmt
    match(:RPAREN, ")")
    body = compoundStatement
    body.stmts.push postop
    while_ = WhileStmt.new(cond, body)
    Statements.new([preop, while_])
  end

  def printStmt
      match(:PRINT, "print")
      tree = binexp(0)
      comp = Types::compatibleTypes(:P_INT, tree.type)
      if comp == :WIDEN_RIGHT
        tree.type = :INT
      end
      #match(:SEMI, ";")
      PrintStmt.new(tree)
  end

  def funccall
    if ((id = @sym.findglob(previous.literal)) == -1)
      error(previous.line,"Undeclared function '#{previous.literal}'")
    end
    if not @sym.names[id]["s_type"] == :S_FUNCTION
      error(previous.line, "Calling a non-function.")
    end
    advance
    match(:LPAREN, "(")
    args = []
    args.push binexp(0)
    match(:RPAREN, ")")
    FuncCall.new(@sym.names[id]["type"], args, id)
  end

  def prefix
    case @token.type
    when :AMPER
      advance
      expr = prefix
      if expr.class != Ident
        error(@token.line, "& must be followed by an identifier")
      end
      Addr.new(Types::pointerTo(expr.type), expr)
    when :STAR
      advance
      expr = prefix
      if expr.class != Ident and expr.class != Deref
        error(@token.line, "* must be followed by an identifier or *")
      end
      Deref.new(Types::valueAt(expr.type), expr)
    else
      primary
    end
  end

  def primary
    n = nil
    case @token.type
    when :NUMBER
      val = @token.literal.to_i
      if  val >= 0 and val < 256
        n = IntLit.new(val, :P_CHAR)
      else
        n = IntLit.new(val, :P_INT)
      end
    when :IDENT
      if peek.type == :LPAREN
        return funccall
      end 
      id = @sym.findglob(@token.literal)
      if(id == -1)
        error(@token.line, "Unknown variable '#{@token.literal}'", @token.type)
      end
      n = Ident.new(@token.literal, id, @sym.names[id]["type"])
    else
      error(@token.line, "syntax error", @token.type)
    end
    advance
    n
  end

  def binexp(prec)

    left = prefix
    token_= @token
    if token_.type == :SEMI || token_.type == :RPAREN
      return left
    end

    while(op_prec(token_) > prec) 
      advance
      right = binexp($opOprec[token_.type])
      comp = Types::compatibleTypes(left.type, right.type)
      case comp
      when :INCOMPATIBLE
        error(@token.line, "incompatible types.")
      when :WIDEN_LEFT
        left.type = :P_INT
      when :WIDEN_RIGHT
        right.type = :P_INT
      end
      left = Binary.new(token_.type, left.type, left, right)

      token_= @token
      if (token_.type == :SEMI || token_.type == :RPAREN)
        return left
      end
    end

    return left
  end


  def advance
    #if(!isAtEnd)
      @current += 1
    #end
    @token = previous
  end

  def isAtEnd
    peek.type == :EOF
  end

  def peek
    @tokens[@current]
  end

  def previous
    @tokens[@current-1]
  end

  def check(type)
    if(@token.type == type)
      return true
    else
      fatal("unexpected #{@token.type}")
    end
  end

  def match(type, what)
    if(@token.type == type)
      advance
      return previous
    else
      error(previous.line, "excpected #{what}", nil)
    end
  end

  def op_prec(token)
    #puts "prec of #{token.type}"
    prec = $opOprec[token.type]
    if(prec == 0 || prec == nil) 
      error(token.line, "psyntax error", token.type)
    end
    prec
  end

  def error(line, message, type=nil)
    puts "Line #{line}: #{message}" + if type then ",token #{type}" else "" end
    exit(1)
  end

  def fatal(message)
    puts  message
    exit(1)
  end

end