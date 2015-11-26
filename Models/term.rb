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

  def step_5(variables, toBeReplaced, constants)
    self.clone
  end
end

class VariableTerm < Term
    
  def initialize(name)
    super(name, nil)
  end

  def step_5(variables, toBeReplaced, constants)
    return self.clone unless toBeReplaced.map { |t| t[:var] }.include? self.name
    obj = toBeReplaced.detect { |v| v[:var].eql? self.name }
    if obj[:bounded]
      terms = variables.map { |var| VariableTerm.new(var)}
      FunctionTerm.new("f", terms)
    else
      if obj[:replacedBy].nil?
        availableConstants = [*('A'..'Z')] - constants
        constants << availableConstants.pop
        obj[:replacedBy] = constants.last
      end
      ConstantTerm.new(obj[:replacedBy])
    end
  end
end

class FunctionTerm < Term

  def initialize(name, terms)
    super(name, terms)
  end

  def pretty_print
    @name + LEFT_PARENTHESIS_SYMBOL + @terms.map { |t| t.pretty_print}.join(",") + RIGHT_PARENTHESIS_SYMBOL
  end

  def step_5(variables, toBeReplaced, constants)
    term = self.clone
    term.terms = @terms.map { |t| s = t.clone; t.step_5(variables.clone, toBeReplaced.clone, constants)}
    term
  end
end