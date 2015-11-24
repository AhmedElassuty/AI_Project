class Sentence
end

class Predicate < Sentence
  @name = nil
  @terms = []

  def initialize(name, terms)
    @name = name
    @terms = terms
  end

  def pretty_print
    @name + LEFT_PARENTHESIS_SYMBOL + @terms.map { |t| t.pretty_print}.join(",") + RIGHT_PARENTHESIS_SYMBOL
  end
end

class ConnectiveSentence < Sentence  
  #
  # A super class for Sentences that have 2 sentences as input
  # Params:
  #      @sentence1: The first sentence
  #      @sentence2: The Second sentence
  #
  @sentence1 = nil
  @sentence2 = nil

  def initialize(sentence1, sentence2)
    @sentence1 = sentence1
    @sentence2 = sentence2
  end

  def print(symbol)
    LEFT_PARENTHESIS_SYMBOL + @sentence1.pretty_print\
      + symbol + @sentence2.pretty_print + RIGHT_PARENTHESIS_SYMBOL
  end

end

class And < ConnectiveSentence
  #
  # Class responsible for holding the ∧ of 2 sentences
  #

  def pretty_print
    print AND_SYMBOL
  end

end

class Or < ConnectiveSentence
  #
  # Class responsible for holding the ∨ of 2 sentences
  #

  def pretty_print
    print OR_SYMBOL
  end

end

class Implication < ConnectiveSentence
  #
  # Class responsible for holding the ⟹ of 2 sentences
  #

  # P ⟹ Q == ¬P ∨ Q
  def resolve
    Or.new(Not.new(@sentence1), @sentence2)
  end

  def pretty_print
    print IMPLICATION_SYMBOL + "  "
  end

end

class BiConditional < ConnectiveSentence
  #
  # Class responsible for holding the ⟺ of 2 sentences
  #

  # P ⟺ Q == (P ⟹ Q) ∧ (Q ⟹ P)
  def resolve
    And.new(Implication.new(@sentence1.clone, @sentence2.clone),
            Implication.new(@sentence2.clone, @sentence1.clone))
  end

  def pretty_print
    print BI_CONDITIONAL_SYMBOL + "  "
  end

end

class Not < Sentence
  #
  # A Class responsible for (¬) of a Sentence
  # Params:
  #      @sentence: A sentence
  #

  @sentence = nil
  
  def initialize(sentence)
    @sentence = sentence
  end

  def pretty_print
    NOT_SYMBOL + LEFT_PARENTHESIS_SYMBOL +  @sentence.pretty_print + RIGHT_PARENTHESIS_SYMBOL
  end

end

class QuantifierSentence  < Sentence
  #
  # Params:
  #      @sentence: sentence which The Quantifier defines
  #      @variable: varibale which The Quantifier defines
  #

  @sentence = nil
  @variable = nil
  
  def initialize(variable, sentence)
    @variable = variable #String
    @sentence = sentence
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

end

class ThereExists < QuantifierSentence 
  #
  # ∃ a subclass of QuantifierSentence
  # A Quantifier Sentence Representing There Exists Sentence
  #

  def pretty_print
    THERE_EXISTS_SYMBOL + @variable + LEFT_BRACKET_SYMBOL + @sentence.pretty_print + RIGHT_BRACKET_SYMBOL
  end

end