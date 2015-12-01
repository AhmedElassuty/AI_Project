#AI Project 2
#Unification and CNF Converter Project
--

Authors             |
--------------------|
Ahmed Elassuty      |
Mohamed Diaa        |

##FOL Representation
###Parser
A subclass of Whittle::Parser class. Its responsible for tokenizing, mapping grammar rules, parsing the input FOL strings to a syntax tree, and mapping the syntax tree to objects (data structures [section 3]).

#### Grammar:
**Tokens**:
	Refer to [section 4], to go through all the types of tokens supported.

**Rules**

    S            -> Sentence

	Atom         -> Sentence | Term

    Sentence 	-> AtomicSentence
						| Sentence Or Sentence
						| Sentence And Sentence
						| Sentence Implies Sentence
						| Sentence Biconditional Sentence
						| QuantifierSentence
						| Quantifier QuantifierSentence
						| NOT Sentence
						| (Sentence)
						| [Sentence]
--
	   AtomicSentence	-> Predicate 
						| Term = Term
  
			Term		-> Constant 
						| Variable
						| Function(Term,...)
			Constant	-> A | ...
			Variable	-> a | ... 
			Predicate	-> PredicateName(TermList)
			Function	-> funcName(TermList)
			TermList    -> TermList , Term | Term

**Grammar Syntax Constants and Regex**
List Of Global Varibales For GRAMMAR Symbols

		- OR_SYMBOL                = "∨"
		- AND_SYMBOL               = "∧"
		- NOT_SYMBOL               = "¬"
		- COMMA_SYMBOL             = ","
		- EQUAL_SYMBOL             = "="
		- FOR_ALL_SYMBOL           = "∀"
		- THERE_EXISTS_SYMBOL      = "∃"
		- BI_CONDITIONAL_SYMBOL    = "⟺"
		- IMPLICATION_SYMBOL       = "⟹"
		- LEFT_BRACKET_SYMBOL      = "["
		- RIGHT_BRACKET_SYMBOL     = "]"
		- LEFT_PARENTHESIS_SYMBOL  = "("
		- RIGHT_PARENTHESIS_SYMBOL = ")"

**List Of Global Varibales For GRAMMAR REGEX**
	
		- ID_REGEX                 = /[A-Z]+[a-zA-Z0-9]*/
		- SMALL_ID_REGEX           = /[a-z]+[a-zA-Z0-9]*/
		- SPACES_REGEX             = /\s+/



##### Notes:

			- Variable:  a string of characters/numbers/underscore that starts with small letter
			- Constant:  a string of characters/numbers/underscore that starts with capital letter
			- Function:  has name equivlant to variable
			- Predicate: has name equivlant to Constant
			- Start State:
				- Unification: Atom
				- CNF Convertor: S

###Data Structures
1. **Sentence**: A super class for all Types of Sentences

		- Predicate: Class responsible for holding Predicate
		- Not: Class responsible for (¬) of a Sentence
		- And: Class responsible for holding the ∧ of 2 sentences
		- Or: Class responsible for holding the ∨ of 2 sentences
		- Implication: Class responsible for holding the ⟹ of 2 sentences
		- Biconditional: Class responsible for holding the ⟺ of 2 sentences
		- ForAll: Quantifier Class Sentence Representing For All Sentence
		- ThereExists: Quantifier Class Sentence Representing There Exists Sentence

2. **Term**:

		- Function: Class representing Function
		- VariableTerm: Class representing Variable
		- ConstantTerm: Class representing Constant

##Modules

###Unifier Module

-
###CNF Module
CNF module is responsible for transforming well-formed FOL sentence into its equivalent CNF. The main method of execution for this module is called “execute”. In order to transform FOL sentence using CNF module you have two options. The default option generates the clausal normal form of the input sentence without printing the intermediate steps the algorithm goes through. It just prints the original FOL sentence and its final clausal form. The second one provides a step by step trace mode which prints the output of each step of the 11 CNF transformation steps.

####Execution Instructions:
- **Regular Mode**:
		
		CNF.execute(fol_sentence)
			* @string fol_sentence
- **Trace Mode**:
		
		CNF.execute(fol_sentence, True)
			* @string fol_sentence
			* @boolean stepTrack --> default False

####Implementation:
CNF module implements the 11 CNF transformation steps introduced in the lecture. Firstly, it parses the input sentence and invokes the first step in the transformation chain.

- #####Step 1:
	Method **“resolve\_bi\_conditional”** is responsible for resolving all bi-conditional implication operators in the supplied sentence. It calls step\_1 method on the parsed sentence. The invocation of step\_1 method will recursively handle all bi-conditional operators. All sentences types implement step\_1 function that forwards the invocation to its sub-associated sentences. Only BiConditional sentence overrides step\_1 function to resolve bi-conditional implication based on:
	
					      P ⟺ Q == (P ⟹ Q) ∧ (Q ⟹ P)
After resolving all bi-conditional implication operators, a new sentence will be returned and passed to the next step.

- #####Step 2:
	Method **“resolve\_implication”** is responsible for resolving all implication operators in the supplied sentence. It calls step\_2 method on the parsed sentence. The invocation of step\_2 method will recursively handle all implication operators. All sentences types implement step\_2 function that forwards the invocation to its sub-associated sentences. Only Implication sentence overrides step\_2 function to resolve implication based on:

         					  	  P ⟹ Q == ¬P ∨ Q
After resolving all implication operators, a new sentence will be returned and passed to the next step.
- #####Step 3:
Method **“move\_negation\_inwards”** invokes step\_3 method that is implemented by all sentence subclasses. “step\_3” function just forwards the invocation to the associated sentences. If step_3 is invoked on Not sentence, the subsequent calls for that branch will use the “negation” method that returns the proper negation of each subsequent sentence type based on:

								   ¬¬(P) == P
								¬(P ∧ Q) == (¬P ∨ ¬Q)
								¬(P ∨ Q) == (¬P ∧ ¬Q)
								  ¬∃x[P] == ∀x[¬P]
								  ¬∀x[P] == ∃x[¬P]
			
- #####Step 4:
Method **“rename\_quantifier\_variables”** is responsible for renaming all overlapped  variables associated with the sentence quantifiers. This method invokes helper method called “standardlize” with the string version of the output from the previous step. “standardlize” method keeps track of the sentence original variables and another array “usedVars” that holds newly generated variables names. Whenever a quantifier is detected, its variable is added to “usedVars”. “standardlize” does not change the first occurrence of the quantifier variable name, although if the quantifier variable exists in the “usedVars” array, new variable from [a-z] is generated and used to replace all occurrences of the quantifier variable in the current quantifier scope.
- #####Step 5:
Method **“skolemize”** is responsible for removing all ∃ quantifiers and replacing their associated variables with new function term of all covering ∀ quantifiers variables as parameters. The generated function name is unique across other functions that exist in the supplied sentence by keeping track of the sentence function names and generating new name from [a-z] for the new function. If ∃ quantifier is not bounded to any ∀ quantifier, its bounded variables is replaced by new constant from [A-Z] that does not already exits in the sentence at all. All variables bounded by the same ∃ quantifier is replaced with the same value. “skolemize” method invokes step\_5 method, that is implemented by all sentence and term data structures, recursively. "step_5" method takes two arguments. The first argument is an array that keeps track of the covering ∀ quantifiers variables in the current execution branch. The second argument is a hash that tracks the variables bounded to ∃ quantifiers and if they are bounded or not. The hash also keeps track of the original replacement of the variable in order to replace subsequent occurrences of the variable with the same value.
- #####Step 6:
Method **"discard_forAll"** invokes "step\_6" method that is implemented by all sentences types. "step\_6" method forwards the execution to sub-sentences. Only ForAll sentence returns its bounded sentence in order to discard this type, then it forwards the invokation on the associated sentence to handle other ForAll quantifiers reqursively.
- #####Step 7:
Method **"conjunctions\_of\_disjunctions"** is responsible for converting the output from the previous step to a conjunctions of disjunctions sentence. This behaviour is carried by step_7 method in order to handle recursive calls and distribute all Or sentences on the associated And sentence using:

						 P ∨ ( Q ∧ S) == (P ∨ Q) ∧ (P ∨ S)

- #####Step 8:
Method **"flatted\_conjunctions\_and\_disjunctions"** invokes "step\_8" method recursively in order to reduce the printed parenthesis based on commutativity and associativity rules that already handled by the orientation of the FOL sentence in objects of Or and And sentences types.
- #####Step 9:
Method "replace\_disjunctions" invokes "step\_9" method recursively in order to pretty print each disjunction sentence as set of clauses by replacing disjunction symbols by "," and wrap them by curly brackets.
- #####Step 10:
Method **"replace\_conjunctions"** invokes "step\_10" method recursively in order to pretty print each disjunction sentence as set of clauses. It prints those clauses as set of the generated sets by replacing conjunction symbols into "," and wrapping the output with curly brackets.
- #####Step 11:
Method **"rename\_clauses\_variables"** ensures that no variable occurs in more than one clause. The method loops through the generated clauses and for each clause it keeps track of its used variables and constants. If any subsequent clause uses any of the tracked symbols we concatenate an integer to the variable represents how many that variable was referenced.

## Output Examples
This section contains screenshots that show the output of running both implemented methods on the supplied test cases.

###Unification

####Sample 1
![sample_1](/Users/assuty/Desktop/Screen Shot 2015-12-01 at 04.00.21.png)
####Sample 2
![sample_2](/Users/assuty/Desktop/Screen Shot 2015-12-01 at 04.03.55.png)
####Sample 3
![sample_3](/Users/assuty/Desktop/Screen Shot 2015-12-01 at 04.05.16.png)

--
###CNF Conversion

####Sentence 1
![CNF Sentence 1](/Users/assuty/Desktop/Screen Shot 2015-12-01 at 03.39.57.png)

####Sentence 2
![CNF Sentence 2](/Users/assuty/Desktop/Screen Shot 2015-12-01 at 03.50.18.png)


## External Libraries
- **Whittle**: Whittle is a LALR(1) parser. You write parsers by specifying sequences of allowable rules (which refer to other rules, or even to themselves). For each rule in your grammar, you provide a block that is invoked when the grammar is recognized.  Whittle takes care of lexer and tokenization jobs. Used in Parser [section 1].
	Source: https://github.com/d11wtq/whittle
- **Colorlize**: a Ruby String class extension. Adds methods to set text color, background color and, text effects on ruby console and command line output, using ANSI escape sequences. Used to colorize the output in the console.
	Source: https://github.com/fazibear/colorize

## How to use (console):
- Must have ruby environment installed.
- If you are using bundler run "bundle install" to install the gems (Libraries).
- The "main.rb" file is the main class, run "ruby main.rb".

## Notes:
- The code is fully documented. 
- The project was implemented from scratch with equivelent load distributed among the team members.