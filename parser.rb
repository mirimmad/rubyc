
require_relative "ast.rb"

$opOprec = {
  :EOF => 0,
  :PLUS => 10,
  :MINUS => 10,
  :STAR => 20,
  :SLASH => 20,
  :NUMBER => 0
}

class Parser
  def initialize(tokens)
    @tokens = tokens
    @current = 0
    @token = nil
  end

  def parse 
    advance
    binexp(0)
  end

  def primary

    case @token.type
    when :NUMBER
      n = IntLit.new(@token.literal)
      advance
      n
    else
      error(@token.line, "syntax error", @token.type)
    end
  end

  def binexp(prec)

    left = primary()
    token_= @token
    if token_.type == :EOF
      return left
    end

    while(op_prec(token_) > prec) 
      advance
      right = binexp($opOprec[token_.type])

      left = Binary.new(token_.type, left, right)

      token_= @token
      if (token_.type == :EOF)
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

  def op_prec(token)
    #puts "prec of #{token.type}"
    prec = $opOprec[token.type]
    if(prec == 0 || prec == nil) 
      error(token.line, "psyntax error", token.type)
    end
    prec
  end

  def error(line, message, type)
    puts "Line #{line}: #{message}, token #{type}"
    exit(1)
  end




end