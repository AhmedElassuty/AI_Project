require "./dependencies"

# Supported Operators
# ⟹, ⟺
# ∧, ∨
# ¬
# ∃, ∀

# --------------------Unification---------------
input1 = "P(x, g(x), g(f(a)))"
input2 = "P(f(u),v,v)"
Unifier.execute(input1, input2, true)

input1 = "P(a, y, f(y))"
input2 = "P(z,z,u)"
Unifier.execute(input1, input2, true)

input1 = "f(x, g(x), x)"
input2 = "f(g(u), g(g(z)), z)"
Unifier.execute(input1, input2, true)

# More examples
# input1 = "Knows(John,x)"
# input2 = "Knows(y, Bill)"
# Unifier.execute(input1, input2, true)

# input1 = "parents(x, father(x), mother(Bill))"
# input2 = "parents(Bill, father(Bill), y)"
# Unifier.execute(input1, input2, true)

# input1 = "parents(x, father(x), mother(Bill))"
# input2 = "parents(Bill, father(y), z)"
# Unifier.execute(input1, input2, true)

# input1 = "parents(x, father(x), mother(Jane))"
# input2 = "parents(Bill, father(y), mother(y))"
# Unifier.execute(input1, input2, true)

# # --------------------CNF---------------------
FOL_sentences = ["∃x[ P(x) ∧ ∀x[Q(x) ⟹ ¬P (x)]]", "∀x[P (x) ⟺ Q(x) ∧ ∃y[Q(y) ∧ R(y, x)]]"]

# More examples
# FOL_sentences = ["∀x[Pc(x) ⟺ ∀z[Q(z)] ∧ ∃y[Q(y) ∧ R(y, x)]] ∧ ∀x[Pc(x) ⟺ Q(x) ∧ ∃y[Q(y) ∧ R(y, x)]] ∧ ∃x[Pc(x) ∧ ∀x[Q(x) ⟹ ¬P (x)]]"]
# FOL_sentences = ["∀x[ ∀y[ Animal(y) ⟹ Loves(x, y)] ⟹ ∃y[Loves(y ,x)]]"]
# FOL_sentences = ["∀x[Martian(x) ⟹ ∃y ∃z[Food(y) ∧ Spice(z) ∧ Contains(y,z) ∧ Likes(x,y)]]"]

FOL_sentences.each do |sentence|
  CNF.execute(sentence, true)
end