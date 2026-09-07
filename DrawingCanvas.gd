extends TextureRect


var canvas_image: Image
var canvas_texture: ImageTexture

var is_drawing: bool = false
var is_eraser: bool = false

var brush_size: int = 10
var draw_color: Color = Color.BLACK

var last_mouse_position: Vector2 = Vector2(-1, -1)

var undo_history: Array[Image] = []
var redo_history: Array[Image] = []

const MAX_HISTORY: int = 50


func _ready() -> void:

	canvas_image = Image.create(
		1000,
		700,
		false,
		Image.FORMAT_RGBA8
	)

	canvas_image.fill(Color.WHITE)

	canvas_texture = ImageTexture.create_from_image(canvas_image)

	self.texture = canvas_texture

	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_SCALE


func _gui_input(event: InputEvent) -> void:

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT:

			is_drawing = event.pressed

			if is_drawing:

				save_undo_state()

				last_mouse_position = event.position

				draw_at_mouse_position(event.position)

			else:

				last_mouse_position = Vector2(-1, -1)


	elif event is InputEventMouseMotion:

		if is_drawing:

			draw_line_between(
				last_mouse_position,
				event.position
			)

			last_mouse_position = event.position


func save_undo_state() -> void:

	undo_history.append(canvas_image.duplicate())

	if undo_history.size() > MAX_HISTORY:

		undo_history.pop_front()

	redo_history.clear()


func draw_at_mouse_position(mouse_pos: Vector2) -> void:

	var pixel_pos: Vector2 = Vector2(
		mouse_pos.x * canvas_image.get_width() / size.x,
		mouse_pos.y * canvas_image.get_height() / size.y
	)

	paint_circle(
		pixel_pos,
		brush_size
	)

	canvas_texture.update(canvas_image)


func draw_line_between(
	start_pos: Vector2,
	end_pos: Vector2
) -> void:

	var distance: float = start_pos.distance_to(end_pos)

	var steps: int = max(
		int(distance),
		1
	)

	for i: int in range(steps + 1):

		var t: float = float(i) / float(steps)

		var current_pos: Vector2 = start_pos.lerp(
			end_pos,
			t
		)

		draw_at_mouse_position(current_pos)


func paint_circle(
	pixel_pos: Vector2,
	radius: int
) -> void:

	var pixel_x: int = int(pixel_pos.x)
	var pixel_y: int = int(pixel_pos.y)

	var paint_color: Color = Color.WHITE

	if not is_eraser:

		paint_color = draw_color

	for x: int in range(
		pixel_x - radius,
		pixel_x + radius + 1
	):

		for y: int in range(
			pixel_y - radius,
			pixel_y + radius + 1
		):

			if x < 0 or x >= canvas_image.get_width():

				continue

			if y < 0 or y >= canvas_image.get_height():

				continue

			var distance: float = Vector2(
				x - pixel_x,
				y - pixel_y
			).length()

			if distance <= float(radius):

				canvas_image.set_pixel(
					x,
					y,
					paint_color
				)


func set_eraser() -> void:

	is_eraser = true


func set_pencil() -> void:

	is_eraser = false


func set_color(color: Color) -> void:

	draw_color = color
	is_eraser = false


func set_brush_size(new_size: int) -> void:

	brush_size = clamp(new_size, 1, 50)


func clear_canvas() -> void:

	save_undo_state()

	canvas_image.fill(Color.WHITE)

	canvas_texture.update(canvas_image)


func undo() -> void:

	if undo_history.is_empty():

		return

	redo_history.append(
		canvas_image.duplicate()
	)

	canvas_image = undo_history.pop_back()

	canvas_texture = ImageTexture.create_from_image(
		canvas_image
	)

	self.texture = canvas_texture


func redo() -> void:

	if redo_history.is_empty():

		return

	undo_history.append(
		canvas_image.duplicate()
	)

	canvas_image = redo_history.pop_back()

	canvas_texture = ImageTexture.create_from_image(
		canvas_image
	)

	self.texture = canvas_texture
