require "whittle"

class Parser < Whittle::Parser

  rule(:wsp => /\s+/).skip!
  rule(EQUAL_SYMBOL) % :left
  rule(THERE_EXISTS_SYMBOL) % :left
  rule(FOR_ALL_SYMBOL) % :left
  
  rule(LEFT_PARENTHESIS_SYMBOL)
  rule(RIGHT_PARENTHESIS_SYMBOL)
  rule(LEFT_BRACKET_SYMBOL)
  rule(RIGHT_BRACKET_SYMBOL)
  rule(COMMA_SYMBOL)
  rule(:not => NOT_SYMBOL) % :left ^ 6
  rule(:and => AND_SYMBOL) % :left ^ 5
  rule(:or  => OR_SYMBOL) % :left ^ 4
  rule(:implies => IMPLICATION_SYMBOL) % :left ^ 3
  rule(:biConditional =>  BI_CONDITIONAL_SYMBOL) % :left ^ 2
 
  rule(:quantifier) do |r|
    r[FOR_ALL_SYMBOL,      :small_identfier].as  { |q, v| {name: q, value: v} }
    r[THERE_EXISTS_SYMBOL, :small_identfier].as  { |q, v| {name: q, value: v} }
  end

  rule(:identfier => ID_REGEX).as {|s| s}
  rule(:small_identfier => SMALL_ID_REGEX).as {|s| s}

  rule(:atomic_sentence) do |r|  
    r[:term, EQUAL_SYMBOL, :term].as { |term1, operator, term2| {equal_sentence: [term1, term1]} }
    r[:predicate]
  end

  rule(:term) do |r|
    r[:func]
    r[:var]
    r[:constant]
  end

  rule(:predicate) do |r|
    r[:identfier, LEFT_PARENTHESIS_SYMBOL , :term_list, RIGHT_PARENTHESIS_SYMBOL].as {|identfier, _,term_list, _| {predicate_sentence: {name: identfier, term_list: term_list} }}
  end

  rule(:func) do |r|
    r[:small_identfier, LEFT_PARENTHESIS_SYMBOL , :term_list, RIGHT_PARENTHESIS_SYMBOL].as {|identfier, _,term_list, _|  {function: {name: identfier, term_list: term_list} } }
  end

  rule(:term_list) do |r|
    r[:term_list, COMMA_SYMBOL , :term].as {|term_list, _, term| [term_list, term].flatten }
    r[:term].as {|term| [term]}
  end

  rule(:constant) do |r|
    r[:identfier].as{ |constant| {constant: constant} }
  end

  rule(:var) do |r|
    r[:small_identfier].as{ |variable| {variable: variable} } % :left
  end

  rule(:sentence) do |r|
    r[:not, :sentence].as { |negate, e| {negated_sentence: {sentence: e} } }
    r[LEFT_PARENTHESIS_SYMBOL, :sentence, RIGHT_PARENTHESIS_SYMBOL].as { |_, e, _| e }
    r[LEFT_BRACKET_SYMBOL, :sentence, RIGHT_BRACKET_SYMBOL].as { |_, e, _| e }
    r[:atomic_sentence]
    r[:sentence, :and, :sentence].as { |a, operator , b| {operator_sentence: {s1: a, operator: operator, s2: b} } }
    r[:sentence, :or, :sentence].as { |a, operator , b| {operator_sentence: {s1: a, operator: operator, s2: b} } }
    r[:sentence, :implies, :sentence].as { |a, operator , b| {operator_sentence: {s1: a, operator: operator, s2: b} } }
    r[:sentence, :biConditional, :sentence].as { |a, operator , b| {operator_sentence: {s1: a, operator: operator, s2: b} } }
    r[:quantifier, :sentence].as { |quantifier, sentence| {quantifier_sentence: {quantifier: quantifier, sentence: sentence} } }
  end

  rule(:s) do |r|
    r[:sentence]
  end

  start(:s)

  def parse_sentence(input)
    syntax_tree = self.parse(input)
    p syntax_tree
    recursive_sentence(syntax_tree)
  end

  def recursive_sentence(syntax_tree)
    case syntax_tree.keys.first
    when :quantifier_sentence
      quantifier_node = syntax_tree[:quantifier_sentence]
      case quantifier_node[:quantifier][:name]
      when FOR_ALL_SYMBOL
        return ForAll.new(quantifier_node[:quantifier][:value], recursive_sentence(quantifier_node[:sentence]))
      when THERE_EXISTS_SYMBOL
        return ThereExists.new(quantifier_node[:quantifier][:value], recursive_sentence(quantifier_node[:sentence]))
      end
    when :operator_sentence
      operator_node = syntax_tree[:operator_sentence]
      sentence1 = recursive_sentence(operator_node[:s1])
      sentence2 = recursive_sentence(operator_node[:s2])
      case operator_node[:operator]
      when BI_CONDITIONAL_SYMBOL
        return BiConditional.new(sentence1,sentence2)
      when IMPLICATION_SYMBOL
        return Implication.new(sentence1,sentence2)
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