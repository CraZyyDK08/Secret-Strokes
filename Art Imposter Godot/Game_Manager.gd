extends Node
class_name GameManager


# ============================================================
# GAME STATES
# ============================================================

enum GameState {
	LOBBY,
	ROUND_DRAWING,
	ROUND_DISCUSSION,
	VOTING,
	IMPOSTER_GUESS,
	RESULT
}


# ============================================================
# SIGNALS
# ============================================================

signal game_state_changed(new_state)
signal round_changed(round_number)
signal timer_changed(time_left)
signal player_ready_changed(player_id, is_ready)

signal voting_started
signal voting_finished

signal imposter_guess_started
signal game_finished(imposter_won)


# ============================================================
# GAME SETTINGS
# ============================================================

@export_category("Game Settings")

@export var number_of_rounds: int = 3

@export var drawing_time: int = 90

@export var discussion_time: int = 60

@export var voting_time: int = 30


# ============================================================
# CURRENT GAME STATE
# ============================================================

var current_state: GameState = GameState.LOBBY

var current_round: int = 0

var time_left: int = 0

var timer_running: bool = false


# ============================================================
# PLAYERS
# ============================================================

# Each player is stored as a Dictionary:
#
# {
#     "id": 1,
#     "name": "Spiller 1",
#     "is_imposter": false,
#     "is_ready": false,
#     "drawing": null
# }

var players: Array = []

var imposter_id: int = -1


# ============================================================
# WORD
# ============================================================

var current_word: String = ""

var current_hint: String = ""


# ============================================================
# DRAWING STATUS
# ============================================================

var finished_drawing_players: Dictionary = {}

var ready_players: Dictionary = {}


# ============================================================
# VOTING
# ============================================================

# Example:
#
# votes[1] = 3
#
# Player 1 voted for Player 3.

var votes: Dictionary = {}

var has_voting_finished: bool = false

var voted_out_player_id: int = -1


# ============================================================
# IMPOSTER GUESS
# ============================================================

var imposter_guess: String = ""

var imposter_guess_correct: bool = false


# ============================================================
# TIMER
# ============================================================

var timer: Timer


# ============================================================
# WORD LIST
# ============================================================

var word_list: Array = [
	{
		"word": "Kat",
		"hint": "Kæledyr"
	},
	{
		"word": "Kirke",
		"hint": "Bygning"
	},
	{
		"word": "Bil",
		"hint": "Transport"
	},
	{
		"word": "Træ",
		"hint": "Natur"
	},
	{
		"word": "Hund",
		"hint": "Kæledyr"
	},
	{
		"word": "Fly",
		"hint": "Transport"
	},
	{
		"word": "Pizza",
		"hint": "Mad"
	},
	{
		"word": "Fodbold",
		"hint": "Sport"
	},
	{
		"word": "Sol",
		"hint": "Natur"
	},
	{
		"word": "Kaffe",
		"hint": "Drik"
	}
]


# ============================================================
# READY
# ============================================================

func _ready() -> void:

	# Create timer
	timer = Timer.new()

	timer.wait_time = 1.0

	timer.one_shot = false

	timer.timeout.connect(_on_timer_tick)

	add_child(timer)

	print("GameManager initialized")


# ============================================================
# START GAME
# ============================================================

func start_game() -> void:

	if players.size() < 2:

		print("Der skal være mindst 2 spillere.")

		return

	reset_game()

	choose_imposter()

	choose_word()

	current_round = 1

	start_drawing_phase()


# ============================================================
# RESET GAME
# ============================================================

func reset_game() -> void:

	stop_timer()

	current_state = GameState.LOBBY

	current_round = 0

	time_left = 0

	imposter_id = -1

	current_word = ""

	current_hint = ""

	finished_drawing_players.clear()

	ready_players.clear()

	votes.clear()

	has_voting_finished = false

	voted_out_player_id = -1

	imposter_guess = ""

	imposter_guess_correct = false


# ============================================================
# CHOOSE IMPOSTER
# ============================================================

func choose_imposter() -> void:

	if players.is_empty():

		return

	# First make sure everyone is NOT imposter.
	for player in players:

		player["is_imposter"] = false

	# Pick random player.
	var random_index: int = randi_range(
		0,
		players.size() - 1
	)

	imposter_id = players[random_index]["id"]

	players[random_index]["is_imposter"] = true

	print(
		"Imposter valgt: Player ",
		imposter_id
	)


# ============================================================
# CHOOSE WORD
# ============================================================

func choose_word() -> void:

	if word_list.is_empty():

		print("Word list is empty.")

		return

	var random_index: int = randi_range(
		0,
		word_list.size() - 1
	)

	var selected_word: Dictionary = word_list[random_index]

	current_word = selected_word["word"]

	current_hint = selected_word["hint"]

	print("Word: ", current_word)

	print("Hint: ", current_hint)


# ============================================================
# START DRAWING
# ============================================================

func start_drawing_phase() -> void:

	stop_timer()

	current_state = GameState.ROUND_DRAWING

	time_left = drawing_time

	finished_drawing_players.clear()

	ready_players.clear()

	for player in players:

		var p_id: int = player["id"]

		ready_players[p_id] = false

		player["is_ready"] = false

	timer_running = true

	timer.start()

	round_changed.emit(current_round)

	game_state_changed.emit(current_state)

	timer_changed.emit(time_left)

	print(
		"Runde ",
		current_round,
		": TEGNING"
	)


# ============================================================
# PLAYER FINISHED DRAWING
# ============================================================

func player_finished_drawing(
	player_id: int
) -> void:

	if current_state != GameState.ROUND_DRAWING:

		return

	if not player_exists(player_id):

		return

	finished_drawing_players[player_id] = true

	ready_players[player_id] = true

	var target_player = get_player(player_id)

	if target_player != null:

		target_player["is_ready"] = true

	player_ready_changed.emit(
		player_id,
		true
	)

	print(
		"Player ",
		player_id,
		" er færdig med at tegne."
	)

	if all_players_finished_drawing():

		start_discussion_phase()


# ============================================================
# PLAYER CANCELS READY
# ============================================================

func player_cancel_ready(
	player_id: int
) -> void:

	if current_state != GameState.ROUND_DRAWING:

		return

	if not player_exists(player_id):

		return

	finished_drawing_players[player_id] = false

	ready_players[player_id] = false

	var target_player = get_player(player_id)

	if target_player != null:

		target_player["is_ready"] = false

	player_ready_changed.emit(
		player_id,
		false
	)

	print(
		"Player ",
		player_id,
		" tegner igen."
	)


# ============================================================
# CHECK IF EVERYONE FINISHED DRAWING
# ============================================================

func all_players_finished_drawing() -> bool:

	if players.is_empty():

		return false

	for player in players:

		var p_id: int = player["id"]

		if not finished_drawing_players.get(
			p_id,
			false
		):

			return false

	return true


# ============================================================
# START DISCUSSION
# ============================================================

func start_discussion_phase() -> void:

	stop_timer()

	current_state = GameState.ROUND_DISCUSSION

	time_left = discussion_time

	timer_running = true

	timer.start()

	game_state_changed.emit(current_state)

	timer_changed.emit(time_left)

	print(
		"Runde ",
		current_round,
		": DISKUSSION"
	)


# ============================================================
# FINISH DISCUSSION
# ============================================================

func finish_discussion() -> void:

	if current_state != GameState.ROUND_DISCUSSION:

		return

	stop_timer()

	# Rounds 1 and 2:
	# Go directly to the next drawing phase.
	#
	# Round 3:
	# Go to voting.

	if current_round < number_of_rounds:

		current_round += 1

		start_drawing_phase()

	else:

		start_voting_phase()


# ============================================================
# START VOTING
# ============================================================

func start_voting_phase() -> void:

	stop_timer()

	current_state = GameState.VOTING

	time_left = voting_time

	votes.clear()

	has_voting_finished = false

	voted_out_player_id = -1

	timer_running = true

	timer.start()

	game_state_changed.emit(current_state)

	voting_started.emit()

	timer_changed.emit(time_left)

	print("AFSTEMNING STARTET")


# ============================================================
# VOTE
# ============================================================

func vote(
	voter_id: int,
	target_player_id: int
) -> void:

	if current_state != GameState.VOTING:

		return

	if not player_exists(voter_id):

		return

	if not player_exists(target_player_id):

		return

	# A player cannot vote for themselves.
	if voter_id == target_player_id:

		return

	# Save vote.
	votes[voter_id] = target_player_id

	print(
		"Player ",
		voter_id,
		" stemte på Player ",
		target_player_id
	)

	# Check if everyone voted.
	if all_players_voted():

		finish_voting()


# ============================================================
# CHECK ALL PLAYERS VOTED
# ============================================================

func all_players_voted() -> bool:

	if players.is_empty():

		return false

	for player in players:

		var p_id: int = player["id"]

		if not votes.has(p_id):

			return false

	return true


# ============================================================
# FINISH VOTING
# ============================================================

func finish_voting() -> void:

	if has_voting_finished:

		return

	has_voting_finished = true

	stop_timer()

	voted_out_player_id = get_most_voted_player()

	voting_finished.emit()

	print(
		"Spiller stemt ud: ",
		voted_out_player_id
	)

	# Was the imposter voted out?
	if voted_out_player_id == imposter_id:

		start_imposter_guess()

	else:

		# Imposter survived.
		end_game(true)


# ============================================================
# FIND PLAYER WITH MOST VOTES
# ============================================================

func get_most_voted_player() -> int:

	if votes.is_empty():

		return -1

	var vote_counts: Dictionary = {}

	for voter_id in votes:

		var target_id: int = votes[voter_id]

		if not vote_counts.has(target_id):

			vote_counts[target_id] = 0

		vote_counts[target_id] += 1

	var highest_votes: int = -1

	var selected_player_id: int = -1

	for target_id in vote_counts:

		var vote_count: int = vote_counts[target_id]

		if vote_count > highest_votes:

			highest_votes = vote_count

			selected_player_id = target_id

	return selected_player_id


# ============================================================
# START IMPOSTER GUESS
# ============================================================

func start_imposter_guess() -> void:

	stop_timer()

	current_state = GameState.IMPOSTER_GUESS

	imposter_guess = ""

	imposter_guess_correct = false

	game_state_changed.emit(current_state)

	imposter_guess_started.emit()

	print(
		"IMPOSTEREN BLEV STEMT UD"
	)

	print(
		"Imposteren skal gætte ordet."
	)


# ============================================================
# SUBMIT IMPOSTER GUESS
# ============================================================

func submit_imposter_guess(
	guess: String
) -> void:

	if current_state != GameState.IMPOSTER_GUESS:

		return

	imposter_guess = guess.strip_edges()

	if imposter_guess.is_empty():

		return

	if imposter_guess.to_lower() == current_word.to_lower():

		imposter_guess_correct = true

		print(
			"Imposteren gættede korrekt!"
		)

		# Imposter wins.
		end_game(true)

	else:

		imposter_guess_correct = false

		print(
			"Imposteren gættede forkert!"
		)

		# Other players win.
		end_game(false)


# ============================================================
# END GAME
# ============================================================

func end_game(
	imposter_won: bool
) -> void:

	stop_timer()

	current_state = GameState.RESULT

	var did_imposter_win: bool = imposter_won

	game_state_changed.emit(current_state)

	game_finished.emit(did_imposter_win)

	print("==============================")

	print("GAME OVER")

	print(
		"Det rigtige ord var: ",
		current_word
	)

	print(
		"Imposter var Player ",
		imposter_id
	)

	if did_imposter_win:

		print("IMPOSTEREN VANDT!")

	else:

		print("DE ANDRE SPILLERE VANDT!")

	print("==============================")


# ============================================================
# TIMER
# ============================================================

func _on_timer_tick() -> void:

	if not timer_running:

		return

	time_left -= 1

	timer_changed.emit(time_left)

	if time_left <= 0:

		time_left = 0

		stop_timer()

		handle_timer_finished()


# ============================================================
# HANDLE TIMER FINISHED
# ============================================================

func handle_timer_finished() -> void:

	match current_state:

		GameState.ROUND_DRAWING:

			print(
				"Tiden er udløbet for tegning."
			)

			# Automatically move to discussion.
			start_discussion_phase()


		GameState.ROUND_DISCUSSION:

			print(
				"Tiden er udløbet for diskussion."
			)

			finish_discussion()


		GameState.VOTING:

			print(
				"Tiden er udløbet for afstemning."
			)

			finish_voting()


		_:

			pass


# ============================================================
# STOP TIMER
# ============================================================

func stop_timer() -> void:

	timer_running = false

	if timer != null:

		timer.stop()


# ============================================================
# ADD PLAYER
# ============================================================

func add_player(
	player_id: int,
	player_name: String
) -> void:

	if player_exists(player_id):

		print(
			"Player ID already exists: ",
			player_id
		)

		return

	var player: Dictionary = {

		"id": player_id,

		"name": player_name,

		"is_imposter": false,

		"is_ready": false,

		"drawing": null
	}

	players.append(player)

	print(
		"Player added: ",
		player_name
	)


# ============================================================
# REMOVE PLAYER
# ============================================================

func remove_player(
	player_id: int
) -> void:

	for i in range(players.size()):

		if players[i]["id"] == player_id:

			players.remove_at(i)

			print(
				"Player removed: ",
				player_id
			)

			return


# ============================================================
# CHECK PLAYER EXISTS
# ============================================================

func player_exists(
	player_id: int
) -> bool:

	for player in players:

		if player["id"] == player_id:

			return true

	return false


# ============================================================
# GET PLAYER
# ============================================================

func get_player(
	player_id: int
):

	for player in players:

		if player["id"] == player_id:

			return player

	return null


# ============================================================
# CHECK IMPOSTER
# ============================================================

func is_imposter(
	player_id: int
) -> bool:

	return player_id == imposter_id


# ============================================================
# GET WORD
# ============================================================

func get_word() -> String:

	return current_word


# ============================================================
# GET HINT
# ============================================================

func get_hint() -> String:

	return current_hint


# ============================================================
# GET STATE
# ============================================================

func get_state() -> GameState:

	return current_state


# ============================================================
# GET ROUND
# ============================================================

func get_round() -> int:

	return current_round


# ============================================================
# GET TIME LEFT
# ============================================================

func get_time_left() -> int:

	return time_left
