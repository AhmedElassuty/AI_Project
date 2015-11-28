require 'colorize'

module Unifier
	@@stepTrack = false

  # Method Signature: execute
  # The unifier module execution method, calls the unificaition and returns its output
  # Params:
  #      @atom1: A sentence or a Term to unifty with @atom2
  #      @atom2: A sentence or a Term to unifty with @atom1
  #      @stepTrack: Boolean that enables/disables printing 
  #                  detailed unification proccess
  #
	def self.execute(atom1, atom2, stepTrack= false)
    puts "----------------- Unificication ---------------------".blue
    puts "Unifying  [ #{atom1.pretty_print} ]  and  [ #{atom2.pretty_print} ]".red
    @@stepTrack = stepTrack
    output = self.unify(atom1, atom2, {})
    self.print_output(output)
  end

  # Method Signature: unify
  # The first step of unification algorithim, called recusivly for compound statements
  # Params:
  #      @atom1: A sentence or a Term to unifty with @atom2
  #      @atom2: A sentence or a Term to unifty with @atom1
  #      @unification_hash: The hash that keeps track of the
  #                         unified { Varibale => Term }
  #
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

  # Method Signature: unify_name
  # Responsible for checking for identical Function names 
  # or Predicate Names. Retuns false otherwise.
  # Params:
  #      @atom1: A sentence or a Term to unifty with @atom2
  #      @atom2: A sentence or a Term to unifty with @atom1
  #      @unification_hash: The hash that keeps track of the
  #                         unified { Varibale => Term }
  #
  def self.unify_name(atom1, atom2, unification_hash)
  	return nil if unification_hash.nil?
		return atom1.name == atom2.name ? unification_hash : nil
  end

  # Method Signature: unify_variable
  # The first step of unification algorithim, called for unifying 
  # variables with term
  # Params:
  #      @variable: A variable
  #      @atom2: A sentence or a Term to unify with @atom1
  #      @unification_hash: The hash that keeps track of the
  #                         unified { Varibale => Term }
  #
  def self.unify_variable(variable, atom, unification_hash)
  	self.print("Unifying Variable #{variable.pretty_print}  with  #{atom.pretty_print}")
		return nil unless atom.is_a?(Term) 
		if !(selected_variable = unification_hash.select {|key, value| key.equals?(variable) }).empty?
			return self.unify(selected_variable.first.last, atom, unification_hash)
		elsif !(selected_variable = unification_hash.select {|key, value| key.equals?(atom) }).empty?
			return self.unify(variable, selected_variable.first.last, unification_hash)
		elsif self.can_not_unify?(variable, atom, unification_hash)
			return nil
		else
			self.update_unification_hash(variable, atom, unification_hash)
			return unification_hash
		end
  end

  # Method Signature: unify_list_of_terms
  # Responsible for unifying a list of terms, for predicates/functions
  # Params:
  #      @list1: List Of Terms to unify with @list2
  #      @list2: List Of Terms to unify with @list1
  #      @unification_hash: The hash that keeps track of the
  #                         unified { Varibale => Term }
  #
  def self.unify_list_of_terms(list1, list2, unification_hash)
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


  # Method Signature: can_not_unify?
  # Responsible for checking if the atom and its content
  # have previosly occured in the unification_hash
  # Params:
  #      @variable: A variable
  #      @atom2: A sentence or a Term to unify with @atom1
  #      @unification_hash: The hash that keeps track of the
  #                         unified { Varibale => Term }
  #
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

  # Method Signature: update_unification_hash
  # Responsible for updating the unification hash, with new 
  # @variable => @atom. Also updates previous functions that have
  # the same @variable in there term list
  # Params:
  #      @variable: A variable
  #      @atom2: A sentence or a Term to unify with @atom1
  #      @unification_hash: The hash that keeps track of the
  #                         unified { Varibale => Term }
  #
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

  # Method Signature: print
  # Responsible for printing string @s if track mode enabled
  # Params:
  #      @s: The String to be printed
  #
  def self.print(s)
  	if @@stepTrack
  		puts s.white
  	end
  end

  # Method Signature: print
  # Responsible for printing the final unification_hash as {var / Term}
  # Params:
  #      @output: the Final unification_hash { Varibale => Term }
  #
  def self.print_output(output)
  	puts "---> UNIFICATION OUTPUT <---".red
  	if output.nil?
  		return print "Failed To Unify"
  	end
  	output_string = "{\n"
  	output.each do |key, value|
  		output_string += "\t{#{key.pretty_print} / #{value.pretty_print}}, \n"
  	end
  	output_string += "}"
  	puts output_string.white
  end
end