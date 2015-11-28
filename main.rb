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
input1 = "Knows(John,x)"
input2 = "Knows(y, Bill)"

input1 = "parents(x, father(x), mother(Bill))"
input2 = "parents(Bill, father(Bill), y)"
result = "{x/Bill, y/mother(Bill)}"

input1 = "parents(x, father(x), mother(Bill))"
input2 = "parents(Bill, father(y), z)"
result = "{x/Bill, y/Bill, z/mother(Bill)}"

input1 = "parents(x, father(x), mother(Jane))"
input2 = "parents(Bill, father(y), mother(y))"
result = "failure"

atom1 = parser.parse_atom(input1)
atom2 = parser.parse_atom(input2)

Unifier.execute(atom1, atom2, true)
# --------------------CNF---------------------
# More sentences
# FOL_sentences = ["∀x ∀y [Philo (x ) ∧ StudentOf (y , x ) ⟹ ∃z[Book(z)∧Write(x,z) ∧ Read(y,z)]]", "∃x∃y[Philo(x) ∧ StudentOf(y,x)]"]

# FOL_sentences = ["∃x[ P(x) ∧ ∀x[Q(x) ⟹ ¬P (x)]]", "∀x[P (x) ⟺ Q(x) ∧ ∃y[Q(y) ∧ R(y, x)]]"]


# FOL_sentences.each do |sentence|
# parsedSentence = parser.parse_sentence(sentence)
# output = CNF.execute(parsedSentence, true)
# # puts parsedSentence.pretty_print
# end

# p1 = Predicate.new("P", [VariableTerm.new("x"), VariableTerm.new("y"), FunctionTerm.new("f", [VariableTerm.new("x")])])
# # # puts p.pretty_print

# p2 = Predicate.new("P", [VariableTerm.new("x"), VariableTerm.new("y"), FunctionTerm.new("f", [VariableTerm.new("x")])])

# andS = And.new(p1,p2)
# orS = Or.new(p1, p2)

# fAll = ForAll.new("s", p1)

# # puts fAll.step_3.inspect