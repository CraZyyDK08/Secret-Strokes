extends Control

@onready var play_button: Button = $Menu/PlayButton
@onready var settings_button: Button = $Menu/SettingsButton
@onready var quit_button: Button = $Menu/QuitButton


func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Art Imposter Godot/Main.tscn")


func _on_settings_pressed() -> void:
	print("Settings")


func _on_quit_pressed() -> void:
	get_tree().quit()
