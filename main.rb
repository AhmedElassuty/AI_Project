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

# input1 = "∀y[ Animal(y) ⟹ Loves(x, y)]"
# input2 = "∀y[ Animal(y) ⟹ Loves(x, y)]"

# input1 = "parents(x, father(x), mother(Jane))"
# input2 = "parents(Bill, father(y), mother(y))"
# result = "failure"

atom1 = parser.parse_atom(input1)
atom2 = parser.parse_atom(input2)

Unifier.execute(atom1, atom2, true)
# --------------------CNF---------------------
# More sentences
# FOL_sentences = ["∀x ∀y [Philo (x ) ∧ StudentOf (y , x ) ⟹ ∃z[Book(z)∧Write(x,z) ∧ Read(y,z)]]", "∃x∃y[Philo(x) ∧ StudentOf(y,x)]"]

# FOL_sentences = ["∃x[ P(x) ∧ ∀x[Q(x) ⟹ ¬P (x)]]", "∀x[P (x) ⟺ Q(x) ∧ ∃y[Q(y) ∧ R(y, x)]]"]

# FOL_sentences = ["∀x[Pc(x) ⟺ ∀z[Q(z)] ∧ ∃y[Q(y) ∧ R(y, x)]] ∧ ∀x[Pc(x) ⟺ Q(x) ∧ ∃y[Q(y) ∧ R(y, x)]] ∧ ∃x[Pc(x) ∧ ∀x[Q(x) ⟹ ¬P (x)]]"]

FOL_sentences = ["∀x[ ∀y[ Animal(y) ⟹ Loves(x, y)] ⟹ ∃y[Loves(y ,x)]]"]

# FOL_sentences = ["∀x[Martian(x) ⟹ ∃y ∃z[Food(y) ∧ Spice(z) ∧ Contains(y,z) ∧ Likes(x,y)]]"]

FOL_sentences.each do |sentence|
  parsedSentence = parser.parse_sentence(sentence)
  output = CNF.execute(parsedSentence, true)
# puts parsedSentence.pretty_print
end