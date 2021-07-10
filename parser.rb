
require_relative "ast.rb"
require_relative "sym.rb"

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
  end

  def parse 
    advance
    compoundStatement
  end

  def compoundStatement
    list = []
    match(:LBRACE, "{")
    while 1
      case @token.type
      when :PRINT
        list.push printStmt
      when :INT
        list.push varDecl
      when :IDENT
        list.push assignmentStmt
      when :IF
        list.push ifStmt
      when :RBRACE
        match(:RBRACE, "}")
        break
      else
        error(@token.line, "Syntax error", @token.type)
      end
    end
    Compoundstatement.new list
  end


  def varDecl
    match(:INT, "int")
    check(:IDENT)
    id = @sym.addglob(@token.literal)
    ident = @token.literal
    advance
    match(:SEMI, ";")
    VarDecl.new(ident, id)
  end

  def assignmentStmt
    check(:IDENT)
    if((id = @sym.findglob(@token.literal)) == -1)
      error(@token.line, "Undeclared variable", @token.literal)
    end
    advance
    right = LVIdent.new(@token.literal, id)
    match(:EQUALS, "=")

    left = binexp(0)
    t = AssignmentStmt.new(left, right)
    match(:SEMI, ";")
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
    else
      puts "no else branch"
    end

    IfStmt.new(cond, thenBranch, elseBranch)

  end


  def printStmt
      match(:PRINT, "print")
      tree = binexp(0)
      match(:SEMI, ";")
      PrintStmt.new(tree)
  end

  

  def primary
    n = nil
    case @token.type
    when :NUMBER
      n = IntLit.new(@token.literal)
    when :IDENT
      id = @sym.findglob(@token.literal)
      if(id == -1)
        error(@token.line, "Unknown variable '#{@token.literal}'", @token.type)
      end
      n = Ident.new(@token.literal, id)
    else
      error(@token.line, "syntax error", @token.type)
    end
    advance
    n
  end

  def binexp(prec)

    left = primary()
    token_= @token
    if token_.type == :SEMI || token_.type == :RPAREN
      return left
    end

    while(op_prec(token_) > prec) 
      advance
      right = binexp($opOprec[token_.type])

      left = Binary.new(token_.type, left, right)

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
      error(previous.line, "excpected #{what}", nil)
    end
  end

  def match(type, what)
    if(@token.type == type)
      advance
      return true
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

  def error(line, message, type)
    puts "Line #{line}: #{message}" + if type then ",token #{type}" else "" end
    exit(1)
  end

  def fatal(message)
    puts message
    exit(1)
  end

end