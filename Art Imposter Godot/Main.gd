extends Node2D

# ============================================================
# EXPORT REFERENCES
# Træk noderne over i felterne i Inspector-vinduet i Godot
# ============================================================

@export var drawing_canvas: Node
@export var pencil_button: Button
@export var eraser_button: Button
@export var clear_button: Button
@export var color_panel: Control
@export var size_slider: HSlider
@export var undo_button: Button
@export var redo_button: Button


# ============================================================
# COLORS
# ============================================================

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


# ============================================================
# READY
# ============================================================

func _ready() -> void:

	# Tjek om knapperne er blevet tilknyttet i Inspector
	if pencil_button:
		pencil_button.pressed.connect(_on_pencil_button_pressed)
	if eraser_button:
		eraser_button.pressed.connect(_on_eraser_button_pressed)
	if clear_button:
		clear_button.pressed.connect(_on_clear_button_pressed)

	if undo_button:
		undo_button.pressed.connect(_on_undo_button_pressed)
	if redo_button:
		redo_button.pressed.connect(_on_redo_button_pressed)

	if size_slider:
		size_slider.min_value = 1
		size_slider.max_value = 50
		size_slider.step = 1
		size_slider.value = 10
		size_slider.value_changed.connect(_on_size_changed)

	# Opsæt farveknapper dynamisk
	if color_panel:
		var color_buttons: Array[Node] = color_panel.get_children()

		for i: int in range(color_buttons.size()):

			if i < colors.size():

				var button: Button = color_buttons[i] as Button

				if button:
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


# ============================================================
# HANDLERS
# ============================================================

func _on_pencil_button_pressed() -> void:

	if drawing_canvas:
		drawing_canvas.set_pencil()


func _on_eraser_button_pressed() -> void:

	if drawing_canvas:
		drawing_canvas.set_eraser()


func _on_clear_button_pressed() -> void:

	if drawing_canvas:
		drawing_canvas.clear_canvas()


func _on_undo_button_pressed() -> void:

	if drawing_canvas:
		drawing_canvas.undo()


func _on_redo_button_pressed() -> void:

	if drawing_canvas:
		drawing_canvas.redo()


func _on_color_pressed(color: Color) -> void:

	if drawing_canvas:
		drawing_canvas.set_color(color)


func _on_size_changed(value: float) -> void:

	if drawing_canvas:
		drawing_canvas.set_brush_size(int(value))
