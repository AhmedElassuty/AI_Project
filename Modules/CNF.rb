require 'colorize'

# CNF transformer module
module CNF

  # @@stepTrack provides trace mode 
  @@stepTrack = false

  # The entery point of CNF transformer module
  # Inputs:
  #   sentence: parsed FOL sentence
  #   @optional stepTrack default False
  def self.execute(sentence, stepTrack= false)
    puts "-----------------CNF Transformation---------------------".blue
    puts "Original FOL sentence: \n".red\
      + sentence.pretty_print
    @@stepTrack = stepTrack
    resolve_bi_conditional sentence
  end

  # Resolving bi-conditional implication
  # Input:
  #   sentence: parsed FOL sentence
  # Output:
  #   returns new sentence that has all bi-conditional implication operators resolved
  def self.resolve_bi_conditional(sentence)
    # Recursively calling method step_1 that is responsible for
    # resolving bi-conditional implication
    output = sentence.step_1
    step_print("Step 1 (resolving bi-conditional implication)", output)
    resolve_implication output
  end

  # Resolving implication
  # Input:
  #   sentence: parsed FOL sentence (output of Step 1)
  # Output:
  #   returns new sentence that has all implication operators resolved
  def self.resolve_implication(sentence)
    # Recursively calling method step_2 that is responsible for
    # resolving implication
    output = sentence.step_2
    step_print("Step 2 (resolving implication)", output)
    move_negation_inwards output
  end

  # Moving not operator inwards
  # Input:
  #   sentence: parsed FOL sentence (output of Step 2)
  # Output:
  #   returns new sentence where all negation signs distributed inwards
  def self.move_negation_inwards(sentence)
    # Recursively calling method step_3 that is responsible for
    # moving ¬ operator inwards
    output = sentence.step_3
    step_print("Step 3 (moving ¬ operator inwards)", output)
    rename_quantifier_variables output
  end

  # Renaming quantifier variables
  # Input:
  #   sentence: parsed FOL sentence (output of Step 3)
  # Output:
  #   returns new sentence that has no overlapped variables
  def self.rename_quantifier_variables(sentence)
    str = standardlize(sentence.pretty_print)
    parser = Parser.new
    output = parser.parse_sentence(str)
    step_print("Step 4 (renaming quantifier variables)", output)
    skolemize output
  end

  # Skolemize
  # Input:
  #   sentence: parsed FOL sentence (output of Step 4)
  # Output:
  #   returns new skolemized sentence
  def self.skolemize(sentence)
    # Extracting sentence constants
    constants = sentence.pretty_print.scan(/[,\(][A-Z]+[a-zA-Z0-9]*[\),]/).map {|c| c[1..-2]}.uniq
    # Recursively calling method step_5 that is responsible for
    # skolemizing ThereExist quantifiers
    output = sentence.step_5([], [], constants)
    step_print("Step 5 (Skolemization)", output)
    discard_forAll output
  end

  # Discard forAll quantifier
  # Input:
  #   sentence: parsed FOL sentence (output of Step 5)
  # Output:
  #   returns new sentence that has no ∀ qunatifier
  def self.discard_forAll(sentence)
    # Recursively calling method step_6 that is responsible for
    # discarding forAll quantifiers
    output = sentence.step_6
    step_print("Step 6 (discarding ∀ quantifier)", output)
    conjunctions_of_disjunctions output
  end

  # Conjunctions of disjunctions
  # Input:
  #   sentence: parsed FOL sentence (output of Step 6)
  # Output:
  #   converts input sentence to conjunctions of disjunctions
  def self.conjunctions_of_disjunctions(sentence)
    # Recursively calling method step_7 that is responsible for
    # distributing disjunctions
    output = sentence.step_7
    step_print("Step 7 (conjunctions of disjunctions)", output)
    flatted_conjunctions_and_disjunctions output
  end

  # Flatten nested conjunctions and disjunctions
  # Input:
  #   sentence: parsed FOL sentence (output of Step 7)
  # Output:
  #   Flattened version of the input sentence (bracket reduced version)
  def self.flatted_conjunctions_and_disjunctions(sentence)
    # Recursively calling method step_8 that is responsible for
    # reducing printed brackets
    output = "  (" + sentence.step_8 + ")"
    puts "- Step 8 (flattening nested conjunctions and disjunctions):\n".red + output.white if @@stepTrack
    replace_disjunctions sentence
  end

  # Remove OR symbols
  # Input:
  #   sentence: parsed FOL sentence (output of Step 7)
  # Output:
  #   converts disjunction blocks into sets
  def self.replace_disjunctions(sentence)
    # Recursively calling method step_9 that is responsible for
    # replacing all disjunction sentences into clause sets
    output = "  {" + sentence.step_9 + "}"
    puts "- Step 9 (removing OR symbols):\n".red + output.white if @@stepTrack
    replace_conjunctions sentence
  end

  # Remove AND symbols
  # Input:
  #   sentence: parsed FOL sentence (output of Step 7)
  # Output:
  #   converts the input sentence into set of clauses
  def self.replace_conjunctions(sentence)
    # Recursively calling method step_10 that is responsible for
    # replacing all conjunction sentences into set of clauses
    output = "{\n  {" + sentence.step_10 + "}\n}"
    puts "- Step 10 (transforming to set of clauses):\n".red + output.white if @@stepTrack
    rename_clauses_variables sentence
  end

  # Rename CNF clauses
  # Input:
  #   sentence: parsed FOL sentence (output of Step 7)
  # Output:
  #   renames clauses variables
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
    puts "- Step 11 (Standardizing clauses):\n".red + output.white
  end

  #  Helper methods

  # Inputs:
  #  msg     : the name of the step
  #  sentence: the output sentence of the corresponding step
  # Output:
  #  prints the input sentence in a readable format using pretty_print method
  def self.step_print(msg, sentence)
    puts ("- "+ msg + ":\n").red\
      + sentence.pretty_print.white if @@stepTrack
  end

  # Inputs:
  #   sentence          : FOL sentence @string
  #   index             : the index of the target boundry symbol
  #   leftBoundrySymbol : opening symbol
  #   rightBoundrySymbol: closing symbol
  # Output:
  #   the range covered by the specified boundries
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

  # Input:
  #  sentence: @string FOL sentence
  # Output:
  #  renames all overlapped variables associated with sentence quantifiers
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