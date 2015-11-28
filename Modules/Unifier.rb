module Unifier
	@@stepTrack = false
	def self.execute(atom1, atom2, stepTrack= false)
    puts "----------------- Unificication ---------------------"
    @@stepTrack = stepTrack
    self.unify(atom1, atom2, {})
  end

  def self.unify(atom1, atom2, hash_map)

  	if hash_map.nil?
  		## Faild to Unify Previous
  		return nil
  	elsif atom1.equals?(atom2)
  		## Identical Atoms
  		return hash_map
  	elsif atom1.instance_of?(VariableTerm)
  		## Variable and Atom
  		return self.unify_variable(atom1, atom2, hash_map)
  	elsif atom2.instance_of?(VariableTerm)
  		## Atom and Variable
  		return self.unify_variable(atom2, atom1, hash_map)
  	elsif (atom1.instance_of?(Predicate) and atom2.instance_of?(Predicate)) or (atom1.instance_of?(FunctionTerm) and atom2.instance_of?(FunctionTerm))
  		## Predicate or Function Sentence
  		return self.unify_list_of_terms(atom1.terms, atom2.terms, self.unify_name(atom1, atom2, hash_map))
  	elsif (atom1.instance_of?(ForAll) and atom2.instance_of?(ForAll)) or (atom1.instance_of?(ThereExists) and atom2.instance_of?(ThereExists))
  		## Quantifier Sentence
  		return self.unify(atom1.sentence, atom2.sentence, self.unify_variable(atom1.variable, atom1.variable, hash_map))
  	elsif (atom1.instance_of?(Not) and atom2.instance_of?(Not))
  		## Not Sentence
  		return self.unify(atom1.sentence, atom2.sentence, hash_map)
  	elsif (atom1.instance_of?(And) and atom2.instance_of?(And)) or (atom1.instance_of?(Or) and atom2.instance_of?(Or)) or (atom1.instance_of?(BiConditional) and atom2.instance_of?(BiConditional)) or (atom1.instance_of?(Implication) and atom2.instance_of?(Implication))
  		## Connective Sentence
  		return self.unify(atom1.sentence2, atom2.sentence2, self.unify(atom1.sentence1, atom2.sentence1(hash_map)))
  	else
  		## Faild to Unify
  		return nil
  	end
  end

  def self.unify_name(atom1, atom2, hash_map)
  	if hash_map.nil?
			return nil
		elsif atom1.name == atom2.name
			return hash_map
		else
			return nil
		end
  end

  def self.unify_variable(variable, atom, hash_map)

  end

  def self.unify_list_of_terms(list1, list2, hash_map)
  	if hash_map.nil? or list1.count != list2.count
  		return nil
  	elsif list1.count == 0
  		return hash_map
  	elsif list1.count == 1
  		return self.unify(list1.first, list2.first, hash_map)
  	else
  		atom1 = list1.pop
  		atom2 = list2.pop
  		new_hash_map = self.unify(atom2, atom2, hash_map)
  		return self.unify_list_of_terms(list1, list2, new_hash_map)
  	end
  end
end