Dir["./*/*.rb"].each {|file| require file }
Dir["./*.rb"].each {|file| require file }



parser = Parser.new

inputs = [ "∃x[P(x)∧∀x[Q(x)⟹¬P(x)]]", "∀x[P (x) ⟺ (Q(x) ∧ ∃y[Q(y) ∧ R(y, x)])]", "B(a)", "¬P (x) ∧ Q(z)" ]

inputs.each do |i|
	p  "Parsing   >>>>>>>>>>   " + i 
	p "-"*200
  p parser.parse_sentence(i)
  p "+"*200
end 


# input = "P(x) ∧ Q(x) ∨ T(x) ⟹ Z(x)"
# p parser.parse_sentence(input)
p "Thank You ;)"


#p parser.parse_sentence(inputs.first)