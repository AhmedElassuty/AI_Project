class Sentence
end

class Predicate < Sentence
  attr_accessor :name, :terms
  @name = nil
  @terms = []

  def initialize(name, terms)
    @name = name
    @terms = terms
  end

  def pretty_print
    @name + LEFT_PARENTHESIS_SYMBOL + @terms.map { |t| t.pretty_print}.join(",") + RIGHT_PARENTHESIS_SYMBOL
  end

  def step_1
    self.clone
  end
  [:step_2, :step_3].each{|method| alias_method method, :step_1}

  def negation
    Not.new(self.clone)
  end
end

class ConnectiveSentence < Sentence
  attr_accessor :sentence1, :sentence2

  #
  # A super class for Sentences that have 2 sentences as input
  # Params:
  #      @sentence1: The first sentence
  #      @sentence2: The Second sentence
  #

  def initialize(sentence1, sentence2)
    @sentence1 = sentence1
    @sentence2 = sentence2
  end

  def print(symbol)
    if @sentence1.instance_of? Predicate and @sentence2.instance_of? Predicate
      @sentence1.pretty_print + " " + symbol + " " + @sentence2.pretty_print
    else
      LEFT_PARENTHESIS_SYMBOL + @sentence1.pretty_print + " " \
      + symbol + " " + @sentence2.pretty_print + RIGHT_PARENTHESIS_SYMBOL
    end
  end

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

end

class And < ConnectiveSentence
  #
  # Class responsible for holding the ∧ of 2 sentences
  #

  def pretty_print
    print AND_SYMBOL
  end

  def negation
    Or.new(@sentence1.negation, @sentence2.negation)
  end

end

class Or < ConnectiveSentence
  #
  # Class responsible for holding the ∨ of 2 sentences
  #

  def pretty_print
    print OR_SYMBOL
  end

  def negation
    And.new(@sentence1.negation, @sentence2.negation)
  end

end

class BiConditional < ConnectiveSentence
  #
  # Class responsible for holding the ⟺ of 2 sentences
  #

  def pretty_print
    print BI_CONDITIONAL_SYMBOL + "  "
  end

  # P ⟺ Q == (P ⟹ Q) ∧ (Q ⟹ P)
  def step_1
    And.new(Implication.new(@sentence1.step_1, @sentence2.step_1),
            Implication.new(@sentence2.step_1, @sentence1.step_1))
  end

end

class Implication < ConnectiveSentence
  #
  # Class responsible for holding the ⟹ of 2 sentences
  #

  def pretty_print
    print IMPLICATION_SYMBOL + "  "
  end

  # P ⟹ Q == ¬P ∨ Q
  def step_2
    Or.new(Not.new(@sentence1.step_2), @sentence2.step_2)
  end

end

class Not < Sentence
  attr_accessor :sentence
  #
  # A Class responsible for (¬) of a Sentence
  # Params:
  #      @sentence: A sentence
  #
  
  def initialize(sentence)
    @sentence = sentence
  end

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
    @sentence.negation
  end

end

class QuantifierSentence  < Sentence
  attr_accessor :sentence, :variable

  #
  # Params:
  #      @sentence: sentence which The Quantifier defines
  #      @variable: varibale which The Quantifier defines
  #

  def initialize(variable, sentence)
    @variable = variable #String
    @sentence = sentence
  end

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

  def pretty_print
    FOR_ALL_SYMBOL + @variable + LEFT_BRACKET_SYMBOL + @sentence.pretty_print + RIGHT_BRACKET_SYMBOL
  end

  def negation
    ThereExists.new(@variable, @sentence.negation)
  end

end

class ThereExists < QuantifierSentence 
  #
  # ∃ a subclass of QuantifierSentence
  # A Quantifier Sentence Representing There Exists Sentence
  #

  def pretty_print
    THERE_EXISTS_SYMBOL + @variable + LEFT_BRACKET_SYMBOL + @sentence.pretty_print + RIGHT_BRACKET_SYMBOL
  end

  def negation
    ForAll.new(@variable, @sentence.negation)
  end

end