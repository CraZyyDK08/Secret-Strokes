extends Node

# Gemmer tegninger fra seneste runde. 
# Key: peer_id (eller navn), Value: ImageTexture
var current_round_drawings: Dictionary = {}

func clear_drawings() -> void:
	current_round_drawings.clear()

func save_drawing(player_id: int, image: Image) -> void:
	var texture = ImageTexture.create_from_image(image)
	current_round_drawings[player_id] = texture
