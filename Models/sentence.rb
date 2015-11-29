class Sentence
  #
  # A super class for all Types of Sentence
  #
end

class Predicate < Sentence
  # Instance Variable
  attr_accessor :name, :terms

  # Class Constructor
  def initialize(name, terms)
    @name = name
    @terms = terms
  end

  # Class Pretty Printer
  def pretty_print
    @name + LEFT_PARENTHESIS_SYMBOL + @terms.map { |t| t.pretty_print}.join(",") + RIGHT_PARENTHESIS_SYMBOL
  end
  [:step_8, :step_9, :step_10].each{|method| alias_method method, :pretty_print}

  # Negation of Predicate sentence
  # ex. P --> ¬P
  def negation
    Not.new(self.clone)
  end

  # CNF helper methods
  def step_1
    self.clone
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

  [:step_2, :step_3, :step_6, :step_7].each{|method| alias_method method, :step_1}

  # Skolemize step
  def step_5(variables, toBeReplaced, constants)
    output = self.clone
    output.terms = @terms.map { |t| t.step_5(variables.clone, toBeReplaced.clone, constants)}
    output
  end

  # Identifies the bounded variables
  def get_used_variables
    @terms.map { |t| t.get_used_variables }
  end
end

class ConnectiveSentence < Sentence
  attr_accessor :sentence1, :sentence2

  ##
  ## A super class for Sentences that have 2 sentences as input
  ## Params:
  ##      @sentence1: The first sentence
  ##      @sentence2: The Second sentence
  ##

  ## Class Constructor
  def initialize(sentence1, sentence2)
    @sentence1 = sentence1
    @sentence2 = sentence2
  end

  def print(symbol)
    LEFT_PARENTHESIS_SYMBOL + @sentence1.pretty_print + " " \
      + symbol + " " + @sentence2.pretty_print + RIGHT_PARENTHESIS_SYMBOL
  end

  # CNF helper methods
  def step_1
    output = self.clone
    output.sentence1 = @sentence1.step_1
    output.sentence2 = @sentence2.step_1
    output
  end

  def step_2
    output = self.clone
    output.sentence1 = @sentence1.step_2
    output.sentence2 = @sentence2.step_2
    output
  end

  def step_3
    output = self.clone
    output.sentence1 = @sentence1.step_3
    output.sentence2 = @sentence2.step_3
    output
  end

  # Skolemize
  def step_5(variables, toBeReplaced, constants)
    output = self.clone
    output.sentence1 = @sentence1.step_5(variables.clone, toBeReplaced.clone, constants)
    output.sentence2 = @sentence2.step_5(variables.clone, toBeReplaced.clone, constants)
    output
  end

  # Discard ∀
  def step_6
    output = self.clone
    output.sentence1 = @sentence1.step_6
    output.sentence2 = @sentence2.step_6
    output
  end

  def equals?(atom)
    if self.instance_of?(atom.class)
      return self.sentence1.equals?(sentence2)
    end
    return false
  end

end

class And < ConnectiveSentence
  ##
  ## Class responsible for holding the ∧ of 2 sentences
  ##

  ## Class Pretty Printer
  def pretty_print
    print AND_SYMBOL
  end

  # Negation of And sentence
  def negation
    Or.new(@sentence1.negation, @sentence2.negation)
  end

  def step_7
    output = self.clone
    output.sentence1 = @sentence1.step_7
    output.sentence2 = @sentence2.step_7
    output
  end

  def step_8
    @sentence1.step_8 + ")\n" + AND_SYMBOL + " (" + @sentence2.step_8
  end

  def step_9
    @sentence1.step_9 + "}\n" + AND_SYMBOL + " {" + @sentence2.step_9
  end

  def step_10
    @sentence1.step_10 + "},\n  {" + @sentence2.step_10
  end

end

class Or < ConnectiveSentence
  ##
  ## Class responsible for holding the ∨ of 2 sentences
  ##

  ## Class Pretty Printer
  def pretty_print
    print OR_SYMBOL
  end

  # Negation of Or sentence
  def negation
    And.new(@sentence1.negation, @sentence2.negation)
  end

  # Disribute disjunctions
  def step_7
    if @sentence2.instance_of? And
      sentence1 = Or.new(@sentence1.clone, @sentence2.sentence1.clone)
      sentence1 = sentence1.step_7
      sentence2 = Or.new(@sentence1.clone, @sentence2.sentence2.clone)
      sentence2 = sentence2.step_7
      And.new(sentence1, sentence2)
    else
      output = self.clone
      output.sentence1 = @sentence1.step_7
      output.sentence2 = @sentence2.step_7
      output
    end
  end

  # custom prints
  def step_8
    @sentence1.step_8 + " " + OR_SYMBOL + " " + @sentence2.step_8
  end

  def step_9
    @sentence1.step_9 + ", " + @sentence2.step_9
  end

  def step_10
    @sentence1.step_10 + ", " + @sentence2.step_10
  end

  # Identifies the bounded variables
  def get_used_variables
    @sentence1.get_used_variables + @sentence2.get_used_variables
  end

end

class BiConditional < ConnectiveSentence
  ##
  ## Class responsible for holding the ⟺ of 2 sentences
  ##

  ## Class Pretty Printer
  def pretty_print
    print BI_CONDITIONAL_SYMBOL + "  "
  end

  # CNF helper methods
  # P ⟺ Q == (P ⟹ Q) ∧ (Q ⟹ P)
  def step_1
    And.new(Implication.new(@sentence1.step_1, @sentence2.step_1),
            Implication.new(@sentence2.step_1, @sentence1.step_1))
  end

end

class Implication < ConnectiveSentence
  ##
  ## Class responsible for holding the ⟹ of 2 sentences
  ##

  # Class Pretty Printer
  def pretty_print
    print IMPLICATION_SYMBOL + "  "
  end

  # CNF helper methods
  # P ⟹ Q == ¬P ∨ Q
  def step_2
    Or.new(Not.new(@sentence1.step_2), @sentence2.step_2)
  end

end

class Not < Sentence
  attr_accessor :sentence
  ##
  ## A Class responsible for (¬) of a Sentence
  ## Params:
  ##      @sentence: A sentence
  ##
  
  ## Class Constructor
  def initialize(sentence)
    @sentence = sentence
  end

  # Class Pretty Printer
  def pretty_print
    if @sentence.instance_of? Predicate
      NOT_SYMBOL +  @sentence.pretty_print 
    else
      NOT_SYMBOL + LEFT_PARENTHESIS_SYMBOL +  @sentence.pretty_print + RIGHT_PARENTHESIS_SYMBOL
    end
  end

  def negation
    @sentence.clone.step_3
  end

  # CNF helper methods
  def step_1
    output = self.clone
    output.sentence = @sentence.step_1
    output
  end

  def step_2
    output = self.clone
    output.sentence = @sentence.step_2
    output
  end

  # move negation inwards
  def step_3
    @sentence.negation
  end

  # Skolemize
  def step_5(variables, toBeReplaced, constants)
    output = self.clone
    output.sentence = @sentence.step_5(variables.clone, toBeReplaced.clone, constants)
    output
  end
  
  ## Discard ∀
  def step_6
    output = self.clone
    output.sentence = @sentence.step_6
    output
  end

  def step_7
    output = self.clone
    output.sentence = @sentence.clone
    output
  end

  def step_8
    NOT_SYMBOL + @sentence.step_8
  end
  [:step_9, :step_10].each{|method| alias_method method, :step_8}

  def get_used_variables
    @sentence.get_used_variables
  end

end

class QuantifierSentence  < Sentence
  attr_accessor :sentence, :variable

  ##
  ## Params:
  ##      @sentence: sentence which The Quantifier defines
  ##      @variable: varibale which The Quantifier defines
  ##

  ## Class Constructor
  def initialize(variable, sentence)
    @variable = variable
    @sentence = sentence
  end

  # CNF helper methods
  def step_1
    output = self.clone
    output.sentence = @sentence.step_1
    output
  end

  def step_2
    output = self.clone
    output.sentence = @sentence.step_2
    output
  end

  def step_3
    output = self.clone
    output.sentence = @sentence.step_3
    output
  end
end

class ForAll < QuantifierSentence 
  #
  # ∀ a subclass of QuantifierSentence
  # A Quantifier Sentence Representing For All Sentence
  # 

  # Class Pretty Printer
  def pretty_print
    FOR_ALL_SYMBOL + @variable.name + LEFT_BRACKET_SYMBOL + @sentence.pretty_print + RIGHT_BRACKET_SYMBOL
  end

  # Negation of ∀ quantifier
  def negation
    ThereExists.new(@variable.clone, @sentence.negation)
  end

  # Skolemize
  def step_5(variables, toBeReplaced, constants)
    output = self.clone
    variables << @variable.name
    output.sentence = @sentence.step_5(variables.clone, toBeReplaced.clone, constants)
    output
  end

  # Discard ∀
  def step_6
    @sentence.clone.step_6
  end

end

class ThereExists < QuantifierSentence 
  ##
  ## ∃ a subclass of QuantifierSentence
  ## A Quantifier Sentence Representing There Exists Sentence
  ##

  # Class Pretty Printer
  def pretty_print
    THERE_EXISTS_SYMBOL + @variable.name + LEFT_BRACKET_SYMBOL + @sentence.pretty_print + RIGHT_BRACKET_SYMBOL
  end

  # Negation of ∃ quantifier
  def negation
    ForAll.new(@variable.clone, @sentence.negation)
  end

  # Skolemize
  def step_5(variables, toBeReplaced, constants)
    toBeReplaced << { var: @variable.name,  bounded: !variables.empty? }
    @sentence.clone.step_5(variables.clone, toBeReplaced.clone, constants)
  end

end