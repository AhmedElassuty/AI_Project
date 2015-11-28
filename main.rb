# Supported Operators
# ⟹, ⟺
# ∧, ∨
# ¬
# ∃, ∀
#------------------------------------------------------
require "./dependencies"

# inputs = [ "∃x[P(x)∧∀x[Q(x)⟹¬P(x)]]", "∀x[P (x) ⟺ (Q(x) ∧ ∃y[Q(y) ∧ R(y, x)])]", "B(a)", "¬P (x) ∧ Q(z)" ]

parser = Parser.new
# --------------------Unification-------------
input1 = "P(a,y)"
input2 = "P(x, f(b))"

input1 = "x(y)"
input2 = "x"

p atom1 = parser.parse_atom(input1)
p atom2 = parser.parse_atom(input2)

puts atom1.equals?(atom2)

Unifier.execute(atom1, atom2, stepTrack= false)
# --------------------CNF---------------------
sentence = "∀x ∀y[ P(y) ∧ Q(x) ⟺ Z(x)]"
parsedSentence = parser.parse_sentence(sentence)

# output = CNF.execute(parsedSentence, true)
# puts output.inspect

# p parsedSentence.pretty_print
# p1 = Predicate.new("P", [VariableTerm.new("x"), VariableTerm.new("y"), FunctionTerm.new("f", [VariableTerm.new("x")])])
# # # puts p.pretty_print

# p2 = Predicate.new("P", [VariableTerm.new("x"), VariableTerm.new("y"), FunctionTerm.new("f", [VariableTerm.new("x")])])

# andS = And.new(p1,p2)
# orS = Or.new(p1, p2)

# fAll = ForAll.new("s", p1)

# # puts fAll.step_3.inspect