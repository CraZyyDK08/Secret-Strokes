extends Control

@onready var ip_input: LineEdit = $CenterContainer/Menu/IPInput
@onready var code_input: LineEdit = $CenterContainer/Menu/CodeInput
@onready var join_button: Button = $CenterContainer/Menu/JoinButton
@onready var back_button: Button = $CenterContainer/Menu/BackButton


func _ready() -> void:

	join_button.pressed.connect(_on_join_pressed)
	back_button.pressed.connect(_on_back_pressed)

	Network.join_failed.connect(_on_join_failed)


func _on_join_pressed() -> void:

	var ip := ip_input.text.strip_edges()
	var code := code_input.text.strip_edges().to_upper()

	if ip.is_empty():
		print("Enter an IP address.")
		return

	if code.length() != 5:
		print("Game code must be 5 characters.")
		return

	var error := Network.join_game(ip, code)

	if error != OK:
		print("Could not connect.")

		return

	get_tree().change_scene_to_file(
		"res://Art Imposter Godot/Lobby.tscn"
	)


func _on_join_failed(message: String) -> void:

	print(message)


func _on_back_pressed() -> void:

	get_tree().change_scene_to_file(
		"res://Art Imposter Godot/MainMenu.tscn"
	)
