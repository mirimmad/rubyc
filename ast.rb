class Node
end

class Expression < Node
end



class IntLit < Expression
  attr_reader :value
  def initialize(value)
    @value = value
  end
  def to_s
    "#{@value}"
  end
end


class Binary < Expression
  attr_reader :a_type, :left, :right
  def initialize(a_type, left, right)
    @a_type = a_type
    @left = left
    @right = right
  end

  def to_s
    "[#{@a_type} #{@left.to_s} #{@right.to_s}]"
  end

end