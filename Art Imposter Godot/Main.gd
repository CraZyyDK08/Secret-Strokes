extends Control


@onready var drawing_canvas = $DrawingCanvas

@onready var pencil_button: Button = $PencilButton
@onready var eraser_button: Button = $EraserButton
@onready var clear_button: Button = $ClearButton

@onready var color_buttons: Array[Node] = $ColorPanel.get_children()
@onready var size_slider: HSlider = $SizeSlider

@onready var undo_button: Button = $UndoButton
@onready var redo_button: Button = $RedoButton

var done_button: Button
var timer_label: Label
var round_timer: Timer
var time_left: int = 60

var colors: Array[Color] = [
	Color.BLACK,
	Color.WHITE,
	Color.RED,
	Color.GREEN,
	Color.BLUE,
	Color.YELLOW,
	Color.ORANGE,
	Color.PURPLE,
	Color.PINK,
	Color.BROWN,
	Color.CYAN,
	Color.GRAY
]


func _ready() -> void:

	pencil_button.pressed.connect(_on_pencil_button_pressed)
	eraser_button.pressed.connect(_on_eraser_button_pressed)
	clear_button.pressed.connect(_on_clear_button_pressed)

	undo_button.pressed.connect(_on_undo_button_pressed)
	redo_button.pressed.connect(_on_redo_button_pressed)

	size_slider.min_value = 1
	size_slider.max_value = 50
	size_slider.step = 1
	size_slider.value = 10

	size_slider.value_changed.connect(_on_size_changed)
	setup_ui_and_timer()

	for i: int in range(color_buttons.size()):

		if i < colors.size():

			var button: Button = color_buttons[i] as Button

			button.pressed.connect(
				_on_color_pressed.bind(colors[i])
			)

			var style_box: StyleBoxFlat = StyleBoxFlat.new()

			style_box.bg_color = colors[i]

			style_box.corner_radius_top_left = 6
			style_box.corner_radius_top_right = 6
			style_box.corner_radius_bottom_left = 6
			style_box.corner_radius_bottom_right = 6

			button.add_theme_stylebox_override(
				"normal",
				style_box
			)

			button.add_theme_stylebox_override(
				"hover",
				style_box
			)

			button.add_theme_stylebox_override(
				"pressed",
				style_box
			)

			button.custom_minimum_size = Vector2(40, 40)


func _on_pencil_button_pressed() -> void:

	drawing_canvas.set_pencil()


func _on_eraser_button_pressed() -> void:

	drawing_canvas.set_eraser()


func _on_clear_button_pressed() -> void:

	drawing_canvas.clear_canvas()


func _on_undo_button_pressed() -> void:

	drawing_canvas.undo()


func _on_redo_button_pressed() -> void:

	drawing_canvas.redo()


func _on_color_pressed(color: Color) -> void:

	drawing_canvas.set_color(color)


func _on_size_changed(value: float) -> void:

	drawing_canvas.set_brush_size(int(value))

func end_drawing_phase() -> void:
	# Gem tegning / send over netværket her, hvis nødvendigt
	round_timer.stop()
	if drawing_canvas and drawing_canvas.canvas_image:
		var my_id = multiplayer.get_unique_id() if multiplayer.has_multiplayer_peer() else 1
		GameData.save_drawing(my_id, drawing_canvas.canvas_image)
		
	get_tree().change_scene_to_file(
		"res://discussion.tscn"
	)

func setup_ui_and_timer() -> void:
	done_button = Button.new()
	done_button.text = "Faerdig / Klar"
	done_button.position = Vector2(20, 320)
	done_button.size = Vector2(100, 50)
	done_button.pressed.connect(_on_done_button_pressed)
	add_child(done_button)

	timer_label = Label.new()
	timer_label.text = "Tid: " + str(time_left)
	timer_label.position = Vector2(150, 10)
	timer_label.add_theme_font_size_override("font_size", 24)
	add_child(timer_label)

	round_timer = Timer.new()
	round_timer.wait_time = 1.0
	round_timer.one_shot = false
	round_timer.timeout.connect(_on_round_timer_timeout)
	add_child(round_timer)
	round_timer.start()


func _on_round_timer_timeout() -> void:
	time_left -= 1
	timer_label.text = "Tid: " + str(time_left)

	if time_left <= 0:
		round_timer.stop()
		end_drawing_phase()


func _on_done_button_pressed() -> void:
	round_timer.stop()
	end_drawing_phase()
