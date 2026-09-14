extends Control

@onready var create_game_button: Button = $Menu/CreateGameButton
@onready var join_game_button: Button = $Menu/JoinGameButton
@onready var quit_button: Button = $Menu/QuitButton


func _ready() -> void:
	create_game_button.pressed.connect(_on_create_game_pressed)
	join_game_button.pressed.connect(_on_join_game_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


func _on_create_game_pressed() -> void:

	var error := Network.create_game()

	if error != OK:
		print("Could not create game. Error code: ", error)
		return

	get_tree().change_scene_to_file(
		"res://lobby.tscn"
		)


func _on_join_game_pressed() -> void:

	get_tree().change_scene_to_file(
		"res://Art Imposter Godot/JoinGame.tscn"
	)


func _on_quit_pressed() -> void:
	get_tree().quit()
