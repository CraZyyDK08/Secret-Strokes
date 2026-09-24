extends Control

@onready var game_code_label: Label = $CenterContainer/MainPanel/Menu/GameCodeLabel
@onready var players_list: Label = $CenterContainer/MainPanel/Menu/PlayersList
@onready var start_game_button: Button = $CenterContainer/MainPanel/Menu/StartGameButton
@onready var back_button: Button = $CenterContainer/MainPanel/Menu/BackButton


func _ready() -> void:
	print("LOBBY LOADED")

	game_code_label.text = "GAME CODE: " + Network.game_code

	players_list.text = "Players:\n"

	for id in Network.players:
		players_list.text += "Player\n"

	start_game_button.visible = multiplayer.is_server()

	start_game_button.pressed.connect(_on_start_game_pressed)
	back_button.pressed.connect(_on_back_pressed)


func _on_start_game_pressed() -> void:
	Network.start_game()


func _on_back_pressed() -> void:
	print("Leaving game...")

	# Luk multiplayer-forbindelsen
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()

	# Gå tilbage til main menu
	get_tree().change_scene_to_file(
		"res://Art Imposter Godot/MainMenu.tscn"
	#multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()

	)
