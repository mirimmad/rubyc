
require_relative "ast.rb"
require_relative "sym.rb"

$opOprec = {
  :EOF => 0,
  :PLUS => 10,
  :MINUS => 10,
  :STAR => 20,
  :SLASH => 20,
  :NUMBER => 0
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
    statements
  end

  def statements
    list = []
    while 1
      case @token.type
      when :PRINT
        list.push printStmt
      when :INT
        list.push varDecl
      when :IDENT
        list.push assignmentStmt
      when :EOF
        break
      else
        error(@token.line, "Syntax error", @token.type)
      end
    end
    Statements.new list
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
    if token_.type == :SEMI
      return left
    end

    while(op_prec(token_) > prec) 
      advance
      right = binexp($opOprec[token_.type])

      left = Binary.new(token_.type, left, right)

      token_= @token
      if (token_.type == :SEMI)
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
    if isAtEnd
      return false
    end
    peek.type == type
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

end