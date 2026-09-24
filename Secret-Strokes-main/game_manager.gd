extends Node


# Det symbol som dette game bruger
var current_symbol = ""


# Hint til imposteren
var current_hint = ""


# Spilleren som er imposter
var imposter_id = ""


# Alle mulige symboler
var symbols = [
	"star",
	"cat",
	"pizza",
	"rocket",
	"tree",
	"heart"
]


# Hvert symbol har forskellige hints
var hints = {
	"star": [
		"night",
		"sky",
		"space"
	],

	"cat": [
		"paw",
		"animal",
		"pet"
	],

	"pizza": [
		"cheese",
		"food",
		"italy"
	],

	"rocket": [
		"space",
		"astronaut",
		"moon"
	],

	"tree": [
		"forest",
		"leaf",
		"nature"
	],

	"heart": [
		"love",
		"valentine",
		"emotion"
	]
}


func start_new_game():
	
	# Vælg et tilfældigt symbol
	current_symbol = symbols.pick_random()
	
	# Vælg et tilfældigt hint til det symbol
	current_hint = hints[current_symbol].pick_random()
	
	print("========== NEW GAME ==========")
	print("Symbol: ", current_symbol)
	print("Hint: ", current_hint)
	print("==============================")
