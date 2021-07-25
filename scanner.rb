#tokens = [:EOF, :INT(type), :PLUS, :MINUS, :STAR, :SLASH, :EQ_EQ, :EQUALS, :NE, :LT, :LE, :GT, :GE, :SEMI, :PRINT, :IDENT, :NNUMBER, :LBRACE, :RBRACE, :IF, :ELSE, :WHILE, :FOR, :VOID, :CHAR, :LONG, :RETURN]

$keywords = {
  "print" => :PRINT,
  "int" => :INT,
  "if" => :IF,
  "else" => :ELSE,
  "while" => :WHILE,
  "for" => :FOR,
  "void" => :VOID,
  "char" => :CHAR,
  "long" => :LONG,
  "return" => :RETURN
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
    when ','
      addToken(:COMMA)
    when '{'
      addToken(:LBRACE)
    when '}'
      addToken(:RBRACE)
    when '('
      addToken(:LPAREN)
    when ')'
      addToken(:RPAREN)
    when '='
      addToken(if match('=') then :EQ_EQ else :EQUALS end)
    when '!'
      addToken(if match('=') then :NE else error(@line, "unexpected character #{c}") end)
    when '>'
      addToken(if match('=') then :GE else :GT end)
    when '<'
      addToken(if match('=') then :LE else :LT end)
    when " ", "\r", "\t", "\f"
    when "\n" 
      @line += 1
    else
      if isDigit(c)
        number()
      elsif isAlpha(c)
        identifier()
      else
        error(@line, "unexpected character #{c}")
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

  def match(expected)
    if isAtEnd
      return false
    end
    if @source[@current] != expected
      return false
    end
    advance
    true
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

