module Unifier
	@@stepTrack = false
	def self.execute(atom1, atom2, stepTrack= false)
    puts "----------------- Unificication ---------------------"
    @@stepTrack = stepTrack
    	# unless atom1.instance_of?(atom2.class)
    	# 	return p atom1.class.name + " is not a " + atom2.class.name
    	# end
    self.unify(atom1, atom2, {})
  end

  def self.unify(atom1, atom2, hash_map)

  	if hash_map.nil? 
  		return nil
  	elsif atom1.equals?(atom2)
  		return hash_map
  	elsif atom1.instance_of?(VariableTerm)
  		return self.unify_variable(atom1, atom2, hash_map)
  	elsif atom2.instance_of?(VariableTerm)
  		return self.unify_variable(atom2, atom1, hash_map)
  	elsif (atom1.instance_of?(Predicate) and atom2.instance_of?(Predicate)) or (atom1.instance_of?(FunctionTerm) and atom2.instance_of?(FunctionTerm))
  		return self.unify_list_of_terms(atom1.terms, atom2.terms, self.unify_name(atom1, atom2, hash_map))
  	elsif (atom1.instance_of?(ForAll) and atom2.instance_of?(ForAll)) or (atom1.instance_of?(ThereExists) and atom2.instance_of?(ThereExists))
  		return self.unify(atom1.sentence, atom2.sentence, self.unify_variable(atom1.variable, atom1.variable, hash_map))
  	elsif (atom1.instance_of?(Not) and atom2.instance_of?(Not))
  		return self.unify(atom1.sentence, atom2.sentence, hash_map)
  	else
  		return nil
  	end
  end

  def self.unify_name(atom1, atom2, hash_map)
  	if (theta == null) 
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