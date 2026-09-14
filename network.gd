extends Node

const PORT := 7777
const MAX_PLAYERS := 8

var game_code: String = ""
var player_name: String = "Player"

var players: Dictionary = {}

signal players_updated
signal game_started
signal join_failed(message)


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


# ==========================================
# CREATE GAME
# ==========================================

func create_game() -> Error:
	var peer := ENetMultiplayerPeer.new()

	var error := peer.create_server(PORT, MAX_PLAYERS)

	if error != OK:
		return error

	multiplayer.multiplayer_peer = peer

	game_code = generate_game_code()

	players.clear()

	# Host always has peer ID 1
	players[1] = player_name

	players_updated.emit()

	print("Game created!")
	print("Game code: ", game_code)

	return OK


# ==========================================
# JOIN GAME
# ==========================================

func join_game(ip_address: String, code: String) -> Error:
	var peer := ENetMultiplayerPeer.new()

	var error := peer.create_client(ip_address, PORT)

	if error != OK:
		return error

	multiplayer.multiplayer_peer = peer

	game_code = code.to_upper()

	print("Trying to join: ", ip_address)
	print("Code: ", game_code)

	return OK


# ==========================================
# RANDOM GAME CODE
# ==========================================

func generate_game_code() -> String:
	var characters := "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"

	var code := ""

	for i in range(5):
		code += characters[randi() % characters.length()]

	return code


# ==========================================
# PLAYER CONNECTED
# ==========================================

func _on_peer_connected(id: int) -> void:
	print("Player connected: ", id)

	if multiplayer.is_server():
		# Tell the new player what the current game looks like.
		send_lobby_info.rpc_id(
			id,
			game_code,
			players
		)


# ==========================================
# PLAYER DISCONNECTED
# ==========================================

func _on_peer_disconnected(id: int) -> void:
	print("Player disconnected: ", id)

	if multiplayer.is_server():
		players.erase(id)

		update_players.rpc(players)


# ==========================================
# CLIENT CONNECTED
# ==========================================

func _on_connected_to_server() -> void:
	print("Connected to server!")

	# Tell the server our name and requested game code.
	request_join.rpc_id(
		1,
		player_name,
		game_code
	)


# ==========================================
# CONNECTION FAILED
# ==========================================

func _on_connection_failed() -> void:
	print("Connection failed!")

	join_failed.emit("Could not connect to the game.")


# ==========================================
# SERVER DISCONNECTED
# ==========================================

func _on_server_disconnected() -> void:
	print("Server disconnected!")

	players.clear()
	players_updated.emit()


# ==========================================
# CLIENT REQUESTS TO JOIN
# ==========================================

@rpc("any_peer", "reliable")
func request_join(name: String, requested_code: String) -> void:

	if not multiplayer.is_server():
		return

	var sender_id := multiplayer.get_remote_sender_id()

	print("Join request from: ", name)
	print("Requested code: ", requested_code)

	# Check game code
	if requested_code != game_code:
		reject_join.rpc_id(
			sender_id,
			"Wrong game code."
		)

		multiplayer.multiplayer_peer.disconnect_peer(sender_id)

		return

	# Check player limit
	if players.size() >= MAX_PLAYERS:
		reject_join.rpc_id(
			sender_id,
			"Game is full."
		)

		multiplayer.multiplayer_peer.disconnect_peer(sender_id)

		return

	# Add player
	players[sender_id] = name

	print("Player accepted: ", name)

	# Update everyone
	update_players.rpc(players)


# ==========================================
# SEND LOBBY INFO
# ==========================================

@rpc("authority", "reliable")
func send_lobby_info(
	new_game_code: String,
	new_players: Dictionary
) -> void:

	game_code = new_game_code
	players = new_players

	players_updated.emit()


# ==========================================
# UPDATE PLAYER LIST
# ==========================================

@rpc("authority", "call_local", "reliable")
func update_players(new_players: Dictionary) -> void:

	players = new_players

	print("Players updated: ", players)

	players_updated.emit()


# ==========================================
# REJECT PLAYER
# ==========================================

@rpc("authority", "reliable")
func reject_join(message: String) -> void:

	print("Join rejected: ", message)

	join_failed.emit(message)


# ==========================================
# START GAME
# ==========================================

func start_game() -> void:

	if not multiplayer.is_server():
		return

	start_game_rpc.rpc()


@rpc("authority", "call_local", "reliable")
func start_game_rpc() -> void:

	print("Starting game!")

	game_started.emit()

	get_tree().change_scene_to_file(
		"res://Art Imposter Godot/Main.tscn"
	)
