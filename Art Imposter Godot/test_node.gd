extends Node

# Husk at trække din GameManager-node over i Inspector, 
# eller tilpas stien i get_node()
@export var game_manager: GameManager

func _ready() -> void:
	if game_manager == null:
		print("Husk at tilknytte GameManager i Inspector!")
		return

	# Lyt til hvornår spillets tilstand ændrer sig
	game_manager.game_state_changed.connect(_on_state_changed)
	game_manager.timer_changed.connect(_on_timer_changed)

	# Start testen
	run_test_game()


func run_test_game() -> void:
	print("--- START DEBUCTEST ---")

	# 1. Tilføj 4 test-spillere
	game_manager.add_player(1, "Spiller 1 (Dig)")
	game_manager.add_player(2, "Bot Anne")
	game_manager.add_player(3, "Bot Bob")
	game_manager.add_player(4, "Bot Charlie")

	# 2. Start spillet
	game_manager.start_game()

	# 3. Simuler at alle spillere trykker 'færdig med at tegne' efter 2 sekunder
	await get_tree().create_timer(2.0).timeout
	print("\n--- SIMULERER AT ALLE TEGNER FÆRDIG ---")
	game_manager.player_finished_drawing(1)
	game_manager.player_finished_drawing(2)
	game_manager.player_finished_drawing(3)
	game_manager.player_finished_drawing(4)


func _on_state_changed(new_state: GameManager.GameState) -> void:
	print("[EVENT] Skiftede til state: ", new_state)

	# Hvis vi når til afstemning, simulerer vi stemmer automatisk
	if new_state == GameManager.GameState.VOTING:
		_simulate_voting()

	# Hvis imPOSTEREN skal gætte
	elif new_state == GameManager.GameState.IMPOSTER_GUESS:
		_simulate_imposter_guess()


func _on_timer_changed(time_left: int) -> void:
	# Udskriver tiden hvert 5. sekund, så konsollen ikke bliver overfyldt
	if time_left % 5 == 0:
		print("Tid tilbage: ", time_left, "s")


func _simulate_voting() -> void:
	await get_tree().create_timer(1.0).timeout
	print("\n--- SIMULERER AFSTEMNING ---")
	
	# Alle stemmer på spiller 2
	game_manager.vote(1, 2)
	game_manager.vote(2, 3)
	game_manager.vote(3, 2)
	game_manager.vote(4, 2)


func _simulate_imposter_guess() -> void:
	await get_tree().create_timer(1.0).timeout
	print("\n--- SIMULERER IMPOSTER GÆT ---")
	
	# Send et gæt afsted
	var correct_word = game_manager.get_word()
	print("Imposteren prøver at gætte ordet: ", correct_word)
	game_manager.submit_imposter_guess(correct_word)
