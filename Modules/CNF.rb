module CNF

  @@stepTrack = false

  def self.execute(sentence, stepTrack= false)
    puts "-----------------CNF Transformation---------------------"
    puts "FOL sentence: \n"\
      + sentence.pretty_print

    @@stepTrack = stepTrack
    resolve_bi_conditional sentence
  end

  # Resolving bi-conditional implication
  def self.resolve_bi_conditional(sentence)
    output = sentence.step_1
    step_print("Step 1 (resolving bi-conditional implication)", output)
    resolve_implication output
  end

  # Resolving implication
  def self.resolve_implication(sentence)
    output = sentence.step_2
    step_print("Step 2 (resolving implication)", output)
    move_negation_inward output
  end

  # Moving not operator inward
  def self.move_negation_inward(sentence)
    output = sentence.step_3
    step_print("Step 3 (moving ¬ operator inward)", output)
    output
  end

  # Renaming quantifier variables
  def self.step4(sentence)
    
    
  end

  # Skolemize
  def self.step5(sentence)
    
    
  end

  # Discard forAll quantifier
  def self.step6(sentence)
    
  end

  # Conjunctions of disjunctions
  def self.step7(sentence)
    
    puts sentence.pretty_print if @@stepTrack
  end

  # Flatten nested conjunctions and disjunctions
  def self.step8(sentence)
    
    
  end

  # remove OR symbols
  def self.step9(sentence)
    
    
  end

  # remove AND symbols
  def self.step10(sentence)
    
    
  end

  # remove rename CNF clauses
  def self.step9(sentence)
    
    
  end

  #  Helper methods
  def self.step_print(msg, sentence)
    puts msg + ":\n"\
      + sentence.pretty_print if @@stepTrack
  end

end