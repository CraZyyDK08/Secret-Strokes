extends Node


# Spillerens rolle
var is_imposter = false


# Det hemmelige ord
var current_word = ""


# Hint til imposteren
var current_hint = ""


# Ord og tilhørende hints
var word_data = {
	"Kat": "Et dyr som mange har som kæledyr",
	"Pizza": "Noget rundt man kan spise",
	"Træ": "Noget der vokser i en skov",
	"Rocket": "Noget der kan flyve ud i rummet",
	"Sol": "Noget man ser på himlen om dagen",
	"Kaffe": "Noget mange drikker om morgenen"
}


func start_new_game():
	
	# Vælg et tilfældigt ord
	var words = word_data.keys()
	current_word = words.pick_random()
	
	# Find hintet til ordet
	current_hint = word_data[current_word]
	
	# Vælg tilfældigt om spilleren er imposter
	is_imposter = randf() < 0.5
	
	print("---------- NYT GAME ----------")
	print("Rolle: ", "IMPOSTER" if is_imposter else "INNO")
	print("Ord: ", current_word)
	print("Hint: ", current_hint)
	print("------------------------------")
