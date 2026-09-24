extends Control


@onready var role_label = $RoleLabel
@onready var symbol_image = $SymbolImage
@onready var hint_label = $HintLabel
@onready var countdown_label = $CountdownLabel
@onready var timer = $Timer


var time_left: int = 5


func _ready():
	
	# Vis spillerens rolle
	show_role()
	
	# Start countdown
	time_left = 5
	countdown_label.text = str(time_left)
	
	# Timeren sender et signal hvert sekund
	timer.wait_time = 1.0
	timer.one_shot = false
	timer.start()


func show_role():
	
	# ==========================================
	# IMPOSTER
	# ==========================================
	
	if RoleGameManager.is_imposter:
		
		role_label.text = "IMPOSTER"
		
		# Imposteren må IKKE se det rigtige ord
		symbol_image.visible = false
		
		# Vis hint
		hint_label.visible = true
		
		hint_label.text = "HINT\n\n" + RoleGameManager.current_hint
	
	
	# ==========================================
	# INNO
	# ==========================================
	
	else:
		
		role_label.text = "INNO"
		
		# Vi bruger ikke billedet endnu
		symbol_image.visible = false
		
		# Inno skal se det rigtige ord
		hint_label.visible = true
		
		hint_label.text = "DIT ORD\n\n" + RoleGameManager.current_word


func _on_timer_timeout():
	
	# Gå et sekund ned
	time_left -= 1
	
	# Opdater teksten
	countdown_label.text = str(time_left)
	
	
	# Hvis tiden er gået
	if time_left <= 0:
		
		# Stop timeren
		timer.stop()
		
		# Gå videre til tegneprogrammet
		get_tree().change_scene_to_file(
			"res://tegne_program.tscn"
		)
