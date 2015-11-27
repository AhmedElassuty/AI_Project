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


# --------------------CNF---------------------
sentence = "∀x[P (x) ⟺ Q(x) ∧ ∃y[Q(y) ∧ R(y, x)]]"
parsedSentence = parser.parse_sentence(sentence)
output = CNF.execute(parsedSentence, true)
# puts parsedSentence.pretty_print

# puts output.inspect

# p1 = Predicate.new("P", [VariableTerm.new("x"), VariableTerm.new("y"), FunctionTerm.new("f", [VariableTerm.new("x")])])
# # # puts p.pretty_print

# p2 = Predicate.new("P", [VariableTerm.new("x"), VariableTerm.new("y"), FunctionTerm.new("f", [VariableTerm.new("x")])])

# andS = And.new(p1,p2)
# orS = Or.new(p1, p2)

# fAll = ForAll.new("s", p1)

# # puts fAll.step_3.inspect