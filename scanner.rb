#tokes = [:EOF, :INT, :PLUS, :MINUS, :STAR, :SLASH]

$keywords = {
  "print" => :PRINT,
  "int" => :INT
}


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
  def inspect 
    to_s
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
    when ';'
      addToken(:SEMI)
    when '='
      addToken(:EQUALS)
    when " "
    when "\r"
    when "\t"
    when "\f"
    when "\n" 
      @line += 1
    else
      if isDigit(c)
        number()
      elsif isAlpha(c)
        identifier()
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

  def isAlpha(c)
    code = c.ord
    (code >= 65 && code <= 90) || (code >= 97 && code <= 122) || code == 95
  end

  def isAlphaNumeric(c)
    isAlpha(c) || isDigit(c)
  end

  def number
    start = @current - 1
    while isDigit(peek)
      advance
    end
    
    addToken(:NUMBER, @source[start..@current-1])
  end
  
  def identifier
    start = @current - 1
    while isAlphaNumeric(peek)
      advance
    end
    literal = @source[start..@current-1]
    if $keywords[literal] != nil
      addToken($keywords[literal], literal)
    else
    addToken(:IDENT, literal)
    end
  end
  
  def addToken(type, literal=nil)
    @tokens.push Token.new(type,literal,@line)
  end

  def error(line, message)
    puts "Line #{line}: #{message}"
    exit(1)
  end

end

