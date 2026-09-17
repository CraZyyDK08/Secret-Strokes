extends Control


@onready var role_label = $RoleLabel
@onready var symbol_image = $SymbolImage
@onready var hint_label = $HintLabel
@onready var countdown_label = $CountdownLabel
@onready var timer = $Timer


var time_left = 5


func _ready():
	
	# Start timeren
	timer.start()
	
	# Vis spillerens rolle
	show_role()
	
	# Opdater countdown
	countdown_label.text = str(time_left)


func show_role():
	
	# MIDlERTIDIG TEST
	
	# Vi starter med at teste Inno
	var is_imposter = false
	
	
	if is_imposter:
		
		role_label.text = "IMPOSTER"
		
		symbol_image.visible = false
		
		hint_label.visible = true
		hint_label.text = "HINT"
		
	else:
		
		role_label.text = "INNO"
		
		symbol_image.visible = true
		
		hint_label.visible = false


func _on_timer_timeout():
	
	# Når kortet er færdigt,
	# går vi til tegnefunktionen
	
	get_tree().change_scene_to_file(
		"res://Art Imposter Godot/Main.tscn"
	)
