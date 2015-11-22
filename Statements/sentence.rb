class Sentence


  def pretty_print
    #
    # Method Responsible For Printing the Stentences Recursively
    #
  end

end

class PredicateSentence < Sentence
  @name = nil
  @terms = []
  def initialize(name, terms)
    @name = name
    @terms = terms
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
end

class AndSentence < ConnectiveSentence
  #
  # Class responsible for holding the ∧ of 2 sentences
  #
end

class OrSentence < ConnectiveSentence
  #
  # Class responsible for holding the ∨ of 2 sentences
  #
end

class ImpliesSentence < ConnectiveSentence
  #
  # Class responsible for holding the ⟹ of 2 sentences
  #
end

class EquivalentSentence < ConnectiveSentence
  #
  # Class responsible for holding the ⟺ of 2 sentences
  #
end

class NotSentence < Sentence

  #
  # A Class responsible for negation of a Sentence
  # Params:
  #      @sentence: A sentence
  #
  @sentence = nil
    def initialize(sentence)
    @sentence = sentence
  end
end

class QuantifierSentence < Sentence
  #
  # A Class responsible for negation of a Sentence
  # Params:
  #      @sentence: sentence which The Quantifier defines
  #      @variable: varibale which The Quantifier defines
  #
  @sentence = nil
  @variable = nil
  def initialize(sentence, variable)
    @sentence = sentence
    @variable = variable
  end
end

class ForAllSentence < QuantifierSentence 
  #
  # ForAllSentence a subclass of QuantifierSentence
  # A Quantifier Sentence Representing For All Sentence
  #
end

class ThereExistsSentence < QuantifierSentence 
  #
  # ThereExistsSentence a subclass of QuantifierSentence
  # A Quantifier Sentence Representing There Exists Sentence
  #
end