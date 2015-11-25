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
    rename_quantifier_variables output
  end

  # Renaming quantifier variables
  def self.rename_quantifier_variables(sentence)
    str = standardlize(sentence.pretty_print)
    parser = Parser.new
    output = parser.parse_sentence(str)
    step_print("Step 4 (renaming quantifier variables)", output)
    output
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

  def self.standardlize(sentence)
    def self.get_scope(sentence, index)
      indexes = []
      count = 0
      loop do
        if sentence[index].eql? "["
          indexes << index
          count += 1
        end
        
        if sentence[index].eql? "]"
          indexes << index
          count -= 1
        end

        index += 1
        break if index >= sentence.length or count == 0
      end
      return indexes.first, indexes.last
    end

    vars = [*('a'..'z')]
    quantifiers = [FOR_ALL_SYMBOL, THERE_EXISTS_SYMBOL]
    usedVars = []

    sentence.length.times do |index|
      if quantifiers.include? sentence[index]
        quantifierVariable = sentence[index += 1]
        startIndex, endIndex = get_scope(sentence, index += 1)

        # rename only repeated Variables
        scope = sentence[startIndex..endIndex]
        usedVars << quantifierVariable
        next unless usedVars.take(usedVars.length - 1).include? quantifierVariable

        # Get new variable
        newVar = vars.shift
        while sentence.include? newVar
          newVar = vars.shift
        end

        # update sentence
        sentence[(startIndex - 1)..endIndex] = sentence[(startIndex - 1)..endIndex].gsub(quantifierVariable, newVar)
      end
    end
    sentence
  end

end