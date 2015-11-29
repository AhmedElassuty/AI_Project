Unification and CNF Convertor Project
##Components:
1. Parser
	A subclass of Whittle::Parser class. Its responsible for tokenizing, mapping grammar rules, parsing the input FOL strings to a syntax tree, and mapping the syntax tree to objects (data structures [section 3]).

	Grammar:
		1. Tokens
			Refer to [section 4], to go through all the types of tokens supported.
		2. Rules
			S           -> Sentence
			Atom        -> Sentence | Term
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

		3. Notes:
			- Variable:  a string of characters/numbers/underscore that starts with small letter
			- Constant:  a string of characters/numbers/underscore that starts with capital letter
			- Function:  has name equivlant to variable
			- Predicate: has name equivlant to Constant
			- Start State:
				- Unification: Atom
				- CNF Convertor: S

2. Modules
	a. Unifier
	b. CNF

3. Data Structures
	a. Sentence: A super class for all Types of Sentences
		- Predicate: Class responsible for holding Predicate
		- Not: Class responsible for (¬) of a Sentence
		- And: Class responsible for holding the ∧ of 2 sentences
		- Or: Class responsible for holding the ∨ of 2 sentences
		- Implication: Class responsible for holding the ⟹ of 2 sentences
		- Biconditional: Class responsible for holding the ⟺ of 2 sentences
		- ForAll: Quantifier Class Sentence Representing For All Sentence
		- ThereExists: Quantifier Class Sentence Representing There Exists Sentence
	b. Term
		- Function: Class representing Function
		- VariableTerm: Class representing Variable
		- ConstantTerm: Class representing Constant

4. Grammar Syntax Constants and Regex
	a. List Of Global Varibales For GRAMMAR Symbols
		OR_SYMBOL                = "∨"
		AND_SYMBOL               = "∧"
		NOT_SYMBOL               = "¬"
		COMMA_SYMBOL             = ","
		EQUAL_SYMBOL             = "="
		FOR_ALL_SYMBOL           = "∀"
		THERE_EXISTS_SYMBOL      = "∃"
		BI_CONDITIONAL_SYMBOL    = "⟺"
		IMPLICATION_SYMBOL       = "⟹"
		LEFT_BRACKET_SYMBOL      = "["
		RIGHT_BRACKET_SYMBOL     = "]"
		LEFT_PARENTHESIS_SYMBOL  = "("
		RIGHT_PARENTHESIS_SYMBOL = ")"

	b. List Of Global Varibales For GRAMMAR REGEX
		ID_REGEX                 = /[A-Z]+[a-zA-Z0-9]*/
		SMALL_ID_REGEX           = /[a-z]+[a-zA-Z0-9]*/
		SPACES_REGEX             = /\s+/

5. External Libraries
	- Whittle: Whittle is a LALR(1) parser. You write parsers by specifying sequences of allowable rules (which refer to other rules, or even to themselves). For each rule in your grammar, you provide a block that is invoked when the grammar is recognized.  Whittle takes care of lexer and tokenization jobs. Used in Parser [section 1].
	Source: https://github.com/d11wtq/whittle
	- Colorlize: a Ruby String class extension. Adds methods to set text color, background color and, text effects on ruby console and command line output, using ANSI escape sequences. Used to colorize the output in the console.
	Source: https://github.com/fazibear/colorize

## Output Examples:
	a. CNF Conversion:
	b. Unification:

## How to use (console):
- Must have ruby environment installed
- If you are using bundler run "bundle install" to install the gems (Libraries)
- The "main.rb" file is the main class, run "ruby main.rb"

## Notes:
The code is fully documented, the project was implemented from scratch with equivelent load distributed among the team members. The contribution and the uniqness of the project can be simply traced, since the project was implemlemnted on a github private repo.
