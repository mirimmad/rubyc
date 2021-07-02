tokes = [:EOF, :INT, :PLUS, :MINUS, :STAR, :SLASH]


class Token
  attr_reader :type, :literal, :line
  def initialize(type, literal, line)
    @type = type
    @literal = literal
    @line = line
  end
  def to_s
    "#{type} #{literal} #{line}"
  end
end

class Scanner
  def initialize(source)
    @source = source
    @current = 0
    @tokens = []
    @line = 1

  end
  def scanTokens
    while (!isAtEnd())
      scanToken()
    end
    addToken(:EOF)
    @tokens
  end

  def scanToken
    c = advance()
    case c
    when '+'
      addToken(:PLUS)
    when '-'
      addToken(:MINUS)
    when '*'
      addToken(:STAR)
    when '/'
    end

  end

  def isAtEnd
    @current >= @source.length
  end

  def advance
    c = @source[@current]
    @current += 1
    c
  end

  def addToken(type, literal=nil)
    @tokens.push Token.new(type,literal,@line)
  end

end

