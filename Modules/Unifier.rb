module Unifier
	@@stepTrack = false
	def self.execute(atom1, atom2, stepTrack= false)
    puts "----------------- Unificication ---------------------"
    puts "Unifying  [ #{atom1.pretty_print} ]    and  [ #{atom2.pretty_print} ]"
    @@stepTrack = true
    output = self.unify(atom1, atom2, {})
    self.print_output(output)
  end

  def self.unify(atom1, atom2, unification_hash)

  	return nil if unification_hash.nil? ## Faild to Unify Previous	
  	if atom1.equals?(atom2)
  		## Identical Atoms
  		return unification_hash
  	elsif atom1.instance_of?(VariableTerm)
  		## Variable and Atom
  		return self.unify_variable(atom1, atom2, unification_hash)
  	elsif atom2.instance_of?(VariableTerm)
  		## Atom and Variable
  		return self.unify_variable(atom2, atom1, unification_hash)
  	elsif (atom1.instance_of?(Predicate) and atom2.instance_of?(Predicate)) or (atom1.instance_of?(FunctionTerm) and atom2.instance_of?(FunctionTerm))
  		## Predicate or Function Sentence
  		return self.unify_list_of_terms(atom1.terms, atom2.terms, self.unify_name(atom1, atom2, unification_hash))
  	elsif (atom1.instance_of?(ForAll) and atom2.instance_of?(ForAll)) or (atom1.instance_of?(ThereExists) and atom2.instance_of?(ThereExists))
  		## Quantifier Sentence
  		return self.unify(atom1.sentence, atom2.sentence, self.unify_variable(atom1.variable, atom1.variable, unification_hash))
  	elsif (atom1.instance_of?(Not) and atom2.instance_of?(Not))
  		## Not Sentence
  		return self.unify(atom1.sentence, atom2.sentence, unification_hash)
  	elsif (atom1.instance_of?(And) and atom2.instance_of?(And)) or (atom1.instance_of?(Or) and atom2.instance_of?(Or)) or (atom1.instance_of?(BiConditional) and atom2.instance_of?(BiConditional)) or (atom1.instance_of?(Implication) and atom2.instance_of?(Implication))
  		## Connective Sentence
  		return self.unify(atom1.sentence2, atom2.sentence2, self.unify(atom1.sentence1, atom2.sentence1(unification_hash)))
  	else
  		## Faild to Unify
  		return nil
  	end
  end

  def self.unify_name(atom1, atom2, unification_hash)
  	return nil if unification_hash.nil?
		return atom1.name == atom2.name ? unification_hash : nil
  end

  def self.unify_variable(variable, atom, unification_hash)
  	self.print("Unifying Variable #{variable.pretty_print}  with  #{atom.pretty_print}")
		return nil unless atom.is_a?(Term) 
		if !(selected_variable = unification_hash.select {|key, value| key.equals?(variable) }).empty?
			## if {var/val} E theta then return UNIFY(val, x, theta)
			return self.unify(selected_variable.first.last, atom, unification_hash)
		elsif !(selected_variable = unification_hash.select {|key, value| key.equals?(atom) }).empty?
			## else if {x/val} E theta then return UNIFY(var, val, theta)
			return self.unify(variable, selected_variable.first.last, unification_hash)
		elsif self.can_not_unify?(variable, atom, unification_hash)

			## if can not unify
			return nil
		else
			## else return add {var/x} to theta
			self.update_unification_hash(variable, atom, unification_hash)
			return unification_hash
		end
  end

  def self.unify_list_of_terms(list1, list2, unification_hash)
  	# self.print("Unifying Lists #{list1}  and  #{list2}")
  	return nil if unification_hash.nil? or list1.count != list2.count
  	case list1.count
  	when 0
  		return unification_hash
  	when 1
  		return self.unify(list1.first, list2.first, unification_hash)
  	else
  		return self.unify_list_of_terms(list1, list2, self.unify( list1.pop, list2.pop, unification_hash))
  	end
  end

  def self.can_not_unify?(variable, atom, unification_hash)
  	return true if variable.equals?(atom)
  	if !(selected_variable = unification_hash.select {|key, value| key.equals?(atom) }).empty?
  		return self.can_not_unify?(variable, selected_variable.first.last, unification_hash)
  	elsif atom.instance_of?(FunctionTerm) 
  		atom.terms.each do |term|
  			return true if self.can_not_unify?(variable, term, unification_hash)
  		end
  	end
  	return false
  end

  def self.update_unification_hash(variable, atom, unification_hash)
  	unification_hash[variable] = atom

  	unification_hash.each do |key, value|
  		if value.instance_of?(Predicate) or value.instance_of?(FunctionTerm)
  			value.terms.each do |term|
  				unless (selected_variable = unification_hash.select {|key, value| key.equals?(term) }).empty?
  					term = selected_variable.first.last
  				end
  			end
  		end
  	end

  end

  def self.print(s)
  	if @@stepTrack
  		puts s
  	end
  end

  def self.print_output(output)
  	print "---> UNIFICATION OUTPUT <---"
  	if output.nil?
  		return print "Failed To Unify"
  	end
  	output_string = "{\n"
  	output.each do |key, value|
  		output_string += "\t{#{key.pretty_print} / #{value.pretty_print}}, \n"
  	end
  	output_string += "}"
  	puts output_string
  end
end