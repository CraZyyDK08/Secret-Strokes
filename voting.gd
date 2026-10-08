extends Control

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var subtitle_label: Label = $VBoxContainer/SubtitleLabel
@onready var timer_label: Label = $VBoxContainer/TimerLabel
@onready var player_grid: GridContainer = $VBoxContainer/ScrollContainer/PlayerGrid

@onready var guess_panel: PanelContainer = $GuessPanel
@onready var word_input: LineEdit = $GuessPanel/VBoxContainer/WordInput
@onready var submit_guess_button: Button = $GuessPanel/VBoxContainer/SubmitGuessButton

@onready var result_panel: PanelContainer = $ResultPanel
@onready var result_label: Label = $ResultPanel/VBoxContainer/ResultLabel
@onready var restart_button: Button = $ResultPanel/VBoxContainer/RestartButton

@onready var timer: Timer = $Timer

# Tidsstyring
var time_left: int = 30
var votes: Dictionary = {} # Key: voter_id, Value: voted_target_id

# Bliver sat dynamisk fra test-setup eller netværk
var local_player_id: int = 1
var impostor_id: int = -1

func _ready() -> void:
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	guess_panel.visible = false
	result_panel.visible = false
	
	submit_guess_button.pressed.connect(_on_submit_guess_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	
	timer.wait_time = 1.0
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

	# Opsæt stemme-kort
	setup_voting_cards()

func setup_voting_cards() -> void:
	for child in player_grid.get_children():
		child.queue_free()

	# Hent spillere/tegninger fra GameData
	var player_ids = GameData.current_round_drawings.keys()
	
	# HVIS DER TESTES ALENE: Opret 3 test-spillere!
	if player_ids.size() <= 1:
		player_ids = [1, 2, 3] # Spiller 1 (Dig), Spiller 2, Spiller 3
		
		# Hvis du i RoleGameManager er sat som Imposter, gør vi dig til Imposter (ID 1)
		# Ellers sætter vi Spiller 2 som Imposter
		if RoleGameManager.is_imposter:
			impostor_id = 1
		else:
			impostor_id = 2

	player_grid.columns = 2 if player_ids.size() <= 4 else 3

	for pid in player_ids:
		var card = PanelContainer.new()
		
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

		var vbox = VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 8)

		# Miniature af tegning
		var img_rect = TextureRect.new()
		if GameData.current_round_drawings.has(pid):
			img_rect.texture = GameData.current_round_drawings[pid]
		img_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		img_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		img_rect.custom_minimum_size = Vector2(240, 180)

		# Spillernavn
		var name_label = Label.new()
		name_label.text = "Spiller " + str(pid)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

		# STEM-knap
		var vote_btn = Button.new()
		vote_btn.text = "Stem på Spiller " + str(pid)
		vote_btn.pressed.connect(func(): _cast_vote(local_player_id, pid))

		vbox.add_child(img_rect)
		vbox.add_child(name_label)
		vbox.add_child(vote_btn)
		card.add_child(vbox)

		player_grid.add_child(card)

func _cast_vote(voter_id: int, target_id: int) -> void:
	votes[voter_id] = target_id
	subtitle_label.text = "Du stemte på Spiller " + str(target_id) + "!"
	
	# I lokal test evaluerer vi med det samme
	_evaluate_votes()

func _on_timer_timeout() -> void:
	time_left -= 1
	timer_label.text = "Tid tilbage: " + str(time_left)
	if time_left <= 0:
		timer.stop()
		_evaluate_votes()

func _evaluate_votes() -> void:
	timer.stop()
	
	# Tæl stemmer op
	var vote_counts: Dictionary = {}
	for voter in votes:
		var target = votes[voter]
		vote_counts[target] = vote_counts.get(target, 0) + 1
	
	var voted_out_id: int = -1
	var max_votes: int = 0
	
	for pid in vote_counts:
		if vote_counts[pid] > max_votes:
			max_votes = vote_counts[pid]
			voted_out_id = pid
			
	# Tjek om den stemte er Imposter
	if voted_out_id == impostor_id:
		# Imposteren blev opdaget -> Skift til ord-gæt skærmen
		$VBoxContainer.visible = false
		guess_panel.visible = true
	else:
		# En innocent blev stemt ud -> Imposter vinder!
		_show_winner("Impostor vinder! En uskyldig blev stemt ud.")

func _on_submit_guess_pressed() -> void:
	var guess = word_input.text.strip_edges()
	var secret_word = RoleGameManager.current_word
	
	# Sammenlign uden at tage højde for store/små bogstaver
	if guess.casecmp_to(secret_word) == 0:
		_show_winner("Impostor gættede ordet '" + secret_word + "' og VINDER!")
	else:
		_show_winner("Impostor gættede '" + guess + "', men ordet var '" + secret_word + "'! De uskyldige VINDER!")

func _show_winner(msg: String) -> void:
	$VBoxContainer.visible = false
	guess_panel.visible = false
	result_panel.visible = true
	result_label.text = msg

func _on_restart_pressed() -> void:
	# 1. Nulstil runde og tegninger
	GameData.reset_game_state()
	
	# 2. Vælg et nyt ord og en ny rolle
	RoleGameManager.start_new_game()
	
	# 3. Gå tilbage til Rollekort-scenen, så man kan se sit nye ord/rolle!
	get_tree().change_scene_to_file("res://role_card.tscn")
