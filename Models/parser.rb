require "whittle"

class Parser < Whittle::Parser
  ## This class includes: 
  ##  FOL grammar rules
  ##  Tokens
  ##  Lexer
  ##  Parsing to objects


  ## Spaces Token
  ## To be Skipped
  rule(:wsp => SPACES_REGEX).skip!

  ## Equal Token
  rule(:equals => EQUAL_SYMBOL)
  
  ## There Exists Token
  rule(:there_exists => THERE_EXISTS_SYMBOL) % :left

  ## For All Token
  rule(:for_all => FOR_ALL_SYMBOL) % :left
  
  ## Left Parenthesis Token
  rule(LEFT_PARENTHESIS_SYMBOL)
  
  ## Right Parenthesis Token
  rule(RIGHT_PARENTHESIS_SYMBOL) 
  
  ## Left Bracket Token
  rule(LEFT_BRACKET_SYMBOL)
  
  ## Right Bracket Token
  rule(RIGHT_BRACKET_SYMBOL)
  
  ## Comma Token
  rule(COMMA_SYMBOL)
  
  ## Not Token
  rule(:not => NOT_SYMBOL) % :left ^ 6
  
  ## And Token
  rule(:and => AND_SYMBOL) % :left ^ 5
  
  ## Or Token
  rule(:or  => OR_SYMBOL) % :left ^ 4
  
  ## Implication Token
  rule(:implies => IMPLICATION_SYMBOL) % :left ^ 3
  
  ## Biconditional Implication Token
  rule(:biConditional =>  BI_CONDITIONAL_SYMBOL) % :left ^ 2
  
  ## Quantifier Rule
  rule(:quantifier) do |r|
    
    ## For All Rule
    r[:for_all,      :small_identfier].as  { |q, v| {name: q, value: v} }

    ## There Exists Rule
    r[:there_exists, :small_identfier].as  { |q, v| {name: q, value: v} }
  end
  
  ## Quantifier Sentence Rule
  rule(:quantifier_sentence) do |r|
    r[:quantifier, LEFT_BRACKET_SYMBOL, :sentence, RIGHT_BRACKET_SYMBOL].as { |quantifier, _ , sentence, _| {quantifier_sentence: {quantifier: quantifier, sentence: sentence} } }
  end
  
  ## Identifier Token
  ## Any String That starts with capital letter, followed by any case insenstive letter, number, or an underscore
  rule(:identfier => ID_REGEX).as {|s| s}
  
  ## Small Identifier Token
  ## Any String That starts with small letter, followed by any case insenstive letter, number, or an underscore
  rule(:small_identfier => SMALL_ID_REGEX).as {|s| s}
  
  ## Atomic Sentence Rule
  rule(:atomic_sentence) do |r| 

    ## Predicate Sentence Rule
    r[:predicate]

    ## Equivilant Sentence Rule
    r[:term, :equals, :term].as { |term1, operator, term2| {equal_sentence: [term1, term1]} }
  end
  
  ## Term Rule
  rule(:term) do |r|

    ## Function Rule
    r[:func]

    ## Variable Token
    r[:var]

    ## Constant Token
    r[:constant]
  end
  
  ## Predicate Sentence Rule
  rule(:predicate) do |r|
    r[:identfier, LEFT_PARENTHESIS_SYMBOL , :term_list, RIGHT_PARENTHESIS_SYMBOL].as {|identfier, _,term_list, _| {predicate_sentence: {name: identfier, term_list: term_list} }}
  end
  
  ## ## Function Rule
  rule(:func) do |r|
    r[:small_identfier, LEFT_PARENTHESIS_SYMBOL , :term_list, RIGHT_PARENTHESIS_SYMBOL].as {|identfier, _,term_list, _|  {function: {name: identfier, term_list: term_list} } }
  end
  
  ## Term List Rule
  rule(:term_list) do |r|
    r[:term_list, COMMA_SYMBOL , :term].as {|term_list, _, term| [term_list, term].flatten }
    r[:term].as {|term| [term]}
  end
  
  ## Constant Token
  rule(:constant) do |r|
    r[:identfier].as{ |constant| {constant: constant} }
  end
  
  ## Variable Token
  rule(:var) do |r|
    r[:small_identfier].as{ |variable| {variable: variable} } % :left
  end
  
  ## Sentence Rule
  rule(:sentence) do |r|

    ## Not Sentence Rule
    r[:not, :sentence].as { |negate, e| {negated_sentence: {sentence: e} } }

    ## Paranthesis Sentence Rule
    r[LEFT_PARENTHESIS_SYMBOL, :sentence, RIGHT_PARENTHESIS_SYMBOL].as { |_, e, _| e }

    ## Bracket Sentence Rule
    r[LEFT_BRACKET_SYMBOL, :sentence, RIGHT_BRACKET_SYMBOL].as { |_, e, _| e }

    ## Atomic Sentence Rule
    r[:atomic_sentence]

    ## And Sentence Rule
    r[:sentence, :and, :sentence].as { |a, operator , b| {operator_sentence: {s1: a, operator: operator, s2: b} } }

    ## Or Sentence Rule
    r[:sentence, :or, :sentence].as { |a, operator , b| {operator_sentence: {s1: a, operator: operator, s2: b} } }

    ## Implication Sentence Rule
    r[:sentence, :implies, :sentence].as { |a, operator , b| {operator_sentence: {s1: a, operator: operator, s2: b} } }

    ## Biconditional Implication Sentence Rule
    r[:sentence, :biConditional, :sentence].as { |a, operator , b| {operator_sentence: {s1: a, operator: operator, s2: b} } }

    ## Mutiple Quantifier Sentence Rule
    r[:quantifier, :quantifier_sentence].as { |quantifier , sentence,| {quantifier_sentence: {quantifier: quantifier, sentence: sentence} } }
    
    ## Quantifier Sentence Rule
    r[:quantifier_sentence]

  end
  
  ## Start Symbol Rule s for (FOL)
  rule(:s) do |r|

    ## Sentence Rule
    r[:sentence]
  end
  
  ## Start Symbol Rule atom for (Unification)
  rule(:atom) do |r|

    ## Sentence Rule
    r[:sentence]

    ## Term Rule
    r[:term]
  end
  
  ## Default Start Symbol
  start(:s)


  # Method Signature: parse_sentence
  # Responsible For Parsing FOL sentences
  # Used for CNF
  # Params:
  #      @input: The sentence string to be parsed
  #
  def parse_sentence(input)
    syntax_tree = self.parse(input)
    recursive_sentence(syntax_tree)
  end

  # Method Signature: parse_atom
  # Responsible For Parsing FOL sentences or Functions
  # Used for Unifier
  # Params:
  #      @input: The sentence string to be parsed
  #
  def parse_atom(input)
    syntax_tree = self.parse(input, :rule => :atom)
    case syntax_tree.keys.first
    when :variable, :constant, :function
      recursiveTerm(syntax_tree)
    else
      recursive_sentence(syntax_tree)
    end
  end

  # Method Signature: recursive_sentence
  # Responsible for wrapping the parser output to Objects (Recursively)
  # Params:
  #      @syntax_tree: The sytax tree (hash) produced by the parser
  #                    The tree is of type Sentence
  #
  def recursive_sentence(syntax_tree)
    case syntax_tree.keys.first
    when :quantifier_sentence
      quantifier_node = syntax_tree[:quantifier_sentence]
      case quantifier_node[:quantifier][:name]
      when FOR_ALL_SYMBOL
        return ForAll.new(VariableTerm.new(quantifier_node[:quantifier][:value]), recursive_sentence(quantifier_node[:sentence]))
      when THERE_EXISTS_SYMBOL
        return ThereExists.new(VariableTerm.new(quantifier_node[:quantifier][:value]), recursive_sentence(quantifier_node[:sentence]))
      end
    when :operator_sentence
      operator_node = syntax_tree[:operator_sentence]
      sentence1 = recursive_sentence(operator_node[:s1])
      sentence2 = recursive_sentence(operator_node[:s2])
      case operator_node[:operator]
      when BI_CONDITIONAL_SYMBOL
        return BiConditional.new(sentence1, sentence2)
      when IMPLICATION_SYMBOL
        return Implication.new(sentence1, sentence2)
      when AND_SYMBOL
        return And.new(sentence1, sentence2)
      when OR_SYMBOL
        return Or.new(sentence1, sentence2)   
      end
    when :negated_sentence
      negated_node = syntax_tree[:negated_sentence]
      sentence = recursive_sentence(negated_node[:sentence])
      return Not.new(sentence)
    when :predicate_sentence
      predicate_node = syntax_tree[:predicate_sentence]
      return Predicate.new(predicate_node[:name], predicate_node[:term_list].map {|t| recursiveTerm(t) })
    when :equal_sentence
      
    end
  end

  # Method Signature: recursiveTerm
  # Responsible for wrapping the parser (Terms) output to Objects Recursively
  # Params:
  #      @term: The term extracted from "recursive_sentence" method
  #             Or recursivly called by recursiveTerm itself
  #
  def recursiveTerm(term)
    case term.keys.first
    when :variable
      return VariableTerm.new(term[:variable])
    when :constant
      return ConstantTerm.new(term[:constant])
    when :function
      function_node = term[:function]
      return FunctionTerm.new(function_node[:name], function_node[:term_list].map {|t| recursiveTerm(t) } )
    end
  end

end