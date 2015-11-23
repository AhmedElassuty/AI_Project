require "./constants"

require Models_PATH + "sentence"
require Models_PATH + "term"
require Models_PATH + "parser"

Dir["./Modules/*.rb"].each {|file| require file }