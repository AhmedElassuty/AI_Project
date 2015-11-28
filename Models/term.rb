class Term 
  attr_accessor :name, :terms
  
  def initialize(name, terms)
    @name = name
    @terms = terms 
  end

  def pretty_print
    @name
  end

  def equals?(atom)
    if self.instance_of?(atom.class)
      return self.name == atom.name
    end
    return false
  end
end

class ConstantTerm < Term 

  def initialize(name)
    super(name, nil)
  end

  def step_5(variables, toBeReplaced, constants)
    self.clone
  end

  def get_used_variables
    @name
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

  def get_used_variables
    @name
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

  def get_used_variables
    @terms.map { |t| t.get_used_variables }
  end

  def equals?(atom)
    if self.instance_of?(atom.class)
      if self.name == atom.name && self.terms.count == atom.terms.count
        self.terms.each_with_index do |term, index|
          return false unless term.equals?(atom.terms[index])
        end
      else
          return false
      end
      return true
    end
    return false
  end
end