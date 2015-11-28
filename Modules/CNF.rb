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
  # Input:
  #   sentence: parsed sentence object describes the FOL sentence
  # Output:
  #   returns new sentence object that has all bi-conditional implication operators resolved
  def self.resolve_bi_conditional(sentence)
    output = sentence.step_1
    step_print("Step 1 (resolving bi-conditional implication)", output)
    resolve_implication output
  end

  # Resolving implication
  # Input:
  #   sentence: parsed sentence object describes the FOL sentence
  # Output:
  #   returns new sentence object that has all implication operators resolved
  def self.resolve_implication(sentence)
    output = sentence.step_2
    step_print("Step 2 (resolving implication)", output)
    move_negation_inwards output
  end

  # Moving not operator inwards
  # Input:
  #   sentence: parsed sentence object describes the FOL sentence
  # Output:
  #   returns new sentence object where all negation signs distributed inwards
  def self.move_negation_inwards(sentence)
    output = sentence.step_3
    step_print("Step 3 (moving ¬ operator inwards)", output)
    rename_quantifier_variables output
  end

  # Renaming quantifier variables
  # Input:
  #   sentence: parsed sentence object describes the FOL sentence
  # Output:
  #   returns new sentence object that has no overlapped variables
  def self.rename_quantifier_variables(sentence)
    str = standardlize(sentence.pretty_print)
    parser = Parser.new
    output = parser.parse_sentence(str)
    step_print("Step 4 (renaming quantifier variables)", output)
    skolemize output
  end

  # Skolemize
  def self.skolemize(sentence)
    constants = sentence.pretty_print.scan(/[,\(][A-Z]+[a-zA-Z0-9]*[\),]/).map {|c| c[1..-2]}.uniq
    output = sentence.step_5([], [], constants)
    step_print("Step 5 (Skolemization)", output)
    discard_forAll output
  end

  # Discard forAll quantifier
  def self.discard_forAll(sentence)
    output = sentence.step_6
    step_print("Step 6 (discarding ∀ quantifier)", output)
    conjunctions_of_disjunctions output
  end

  # Conjunctions of disjunctions
  def self.conjunctions_of_disjunctions(sentence)
    output = sentence.step_7
    step_print("Step 7 (conjunctions of disjunctions)", output)
    flatted_conjunctions_and_disjunctions output
  end

  # Flatten nested conjunctions and disjunctions
  def self.flatted_conjunctions_and_disjunctions(sentence)
    output = "  (" + sentence.step_8 + ")"
    puts "Step 8 (flattening nested conjunctions and disjunctions):\n" + output if @@stepTrack
    replace_disjunctions sentence
  end

  # remove OR symbols
  def self.replace_disjunctions(sentence)
    output = "  {" + sentence.step_9 + "}"
    puts "Step 9 (removing OR symbols):\n" + output if @@stepTrack
    replace_conjunctions sentence
  end

  # remove AND symbols
  def self.replace_conjunctions(sentence)
    output = "{\n  {" + sentence.step_10 + "}\n}"
    puts "Step 10 (transforming to set of clauses):\n" + output if @@stepTrack
    rename_clauses_variables sentence
  end

  # rename CNF clauses
  def self.rename_clauses_variables(sentence)
    splittedSentence = ("(" + sentence.step_8 + ")").split("∧").map { |t| t.strip }
    usedVars = []
    output = "{\n"

    parser = Parser.new
    splittedSentence.each do |clause|
      parsed = parser.parse_sentence(clause)
      vars = parsed.get_used_variables.flatten.uniq

      unless (intersection = (vars & usedVars)).empty?
        intersection.each do |to_be_renamed|
          number = usedVars.select { |e| e.eql? to_be_renamed}.count
          clause = clause.gsub(/(?<=[,\(])#{to_be_renamed}(?=[,\)])/, to_be_renamed + number.to_s)
        end
      end
      
      clause = clause.gsub(" ∨", ",")
      clause[0] = "{"
      clause[clause.length - 1] = "},"

      output += "  " + clause + "\n"
      usedVars += vars
    end
    output[output.length - 2] = ""
    output += "}"
    puts "Step 11 (Standardizing clauses):\n" + output
  end

  #  Helper methods
  def self.step_print(msg, sentence)
    puts "- "+ msg + ":\n"\
      + sentence.pretty_print if @@stepTrack
  end

  def self.get_scope(sentence, index, leftBoundrySymbol, rightBoundrySymbol)
    indexes = []
    count = 0
    loop do
      if sentence[index].eql? leftBoundrySymbol
        indexes << index
        count += 1
      end

      if sentence[index].eql? rightBoundrySymbol
        indexes << index
        count -= 1
      end

      index += 1
      break if index >= sentence.length or count == 0
    end
    return indexes.first, indexes.last
  end

  def self.standardlize(sentence)
    vars = [*('a'..'z')]
    quantifiers = [FOR_ALL_SYMBOL, THERE_EXISTS_SYMBOL]
    usedVars = []

    sentence.length.times do |index|
      if quantifiers.include? sentence[index]
        quantifierVariable = sentence[index += 1]
        startIndex, endIndex = get_scope(sentence, index += 1, "[", "]")

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