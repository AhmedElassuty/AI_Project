class Term 
  @name = ""
  @terms = nil
    def initialize(name, terms)
    @name = name
    @terms = terms 
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
end