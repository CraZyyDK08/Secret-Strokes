extends Control

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var timer_label: Label = $VBoxContainer/TimerLabel
@onready var drawing_grid: GridContainer = $VBoxContainer/ScrollContainer/DrawingGrid
@onready var timer: Timer = $Timer

var time_left: int = 20

func _ready() -> void:
	title_label.text = "DISKUSSIONSRUNDE"
	timer_label.text = "Tid tilbage: " + str(time_left)

	timer.wait_time = 1.0
	timer.one_shot = false
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

	# Vis tegningerne fra seneste runde
	display_drawings()

func display_drawings() -> void:
	for child in drawing_grid.get_children():
		child.queue_free()

	var player_count: int = GameData.current_round_drawings.size()
	if player_count == 0:
		return

	# Tilpas billedstørrelse efter antal spillere
	var img_size: Vector2
	if player_count == 1:
		drawing_grid.columns = 1
		img_size = Vector2(480, 360)
	elif player_count == 2:
		drawing_grid.columns = 2
		img_size = Vector2(380, 285)
	elif player_count <= 4:
		drawing_grid.columns = 2
		img_size = Vector2(300, 225)
	else:
		drawing_grid.columns = 3
		img_size = Vector2(220, 165)

	for player_id in GameData.current_round_drawings:
		var texture = GameData.current_round_drawings[player_id]
		
		# Kort-container
		var card = PanelContainer.new()
		
		# Pæn mørk baggrund med runde hjørner
		var style_box = StyleBoxFlat.new()
		style_box.bg_color = Color(0.15, 0.17, 0.23, 0.95)
		style_box.corner_radius_top_left = 12
		style_box.corner_radius_top_right = 12
		style_box.corner_radius_bottom_left = 12
		style_box.corner_radius_bottom_right = 12
		style_box.content_margin_left = 12
		style_box.content_margin_top = 12
		style_box.content_margin_right = 12
		style_box.content_margin_bottom = 12
		card.add_theme_stylebox_override("panel", style_box)
		
		# VBox til billede + navn
		var vbox = VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 10)
		
		# Tegning-billede
		var img_rect = TextureRect.new()
		img_rect.texture = texture
		img_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		img_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		img_rect.custom_minimum_size = img_size
		
		# Spillernavn
		var name_label = Label.new()
		name_label.text = "Spiller " + str(player_id)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.add_theme_font_size_override("font_size", 16)
		
		vbox.add_child(img_rect)
		vbox.add_child(name_label)
		card.add_child(vbox)
		
		drawing_grid.add_child(card)

func _on_timer_timeout() -> void:
	time_left -= 1
	timer_label.text = "Tid tilbage: " + str(time_left)

	if time_left <= 0:
		timer.stop()
		_go_to_next_round()

func _go_to_next_round() -> void:
	# Nulstil tegninger til næste runde hvis nødvendigt
	# GameData.clear_drawings()
	
	if multiplayer.has_multiplayer_peer() and multiplayer.is_server():
		Network.change_to_drawing_scene_rpc.rpc()
	elif not multiplayer.has_multiplayer_peer():
		get_tree().change_scene_to_file("res://tegne_program.tscn")
