#tokes = [:EOF, :INT, :PLUS, :MINUS, :STAR, :SLASH]


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
      addToken(:SLASH)
    when " " || "\t" || "\r" || "\f"
    when "\n"
      @line += 1
    else
      if isDigit(c)
        number()
      else
        error(@line, "unexpected character #{c.ord}")
      end

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

  def peek
    if isAtEnd
      return '\0'
    end
    @source[@current]
  end

  def isDigit(c)
    code = c.ord
    48 <= code && code <= 57
  end

  def number
    start = @current - 1
    while isDigit(peek)
      advance
    end
    
    addToken(:NUMBER, @source[start..@current-1])
  end

  def addToken(type, literal=nil)
    @tokens.push Token.new(type,literal,@line)
  end

  def error(line, message)
    puts "Line #{line}: #{message}"
    exit(1)
  end

end

