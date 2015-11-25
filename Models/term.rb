class Term 
  attr_accessor :name, :terms
  
  def initialize(name, terms)
    @name = name
    @terms = terms 
  end

  def pretty_print
    @name
  end
end

class ConstantTerm < Term 

  def initialize(name)
    super(name, nil)
  end
end

class VariableTerm < Term
    
  def initialize(name)
    super(name, nil)
  end
end

class FunctionTerm < Term

  def initialize(name, terms)
    super(name, terms)
  end

  def pretty_print
    @name + LEFT_PARENTHESIS_SYMBOL + @terms.map { |t| t.pretty_print}.join(",") + RIGHT_PARENTHESIS_SYMBOL
  end
end