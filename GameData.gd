extends Node

# Gemmer tegninger fra seneste runde. 
# Key: peer_id (eller spiller-ID), Value: ImageTexture
var current_round_drawings: Dictionary = {}

# Runde-styring
var current_round: int = 1
var max_rounds: int = 3

# Gemmer tegning sendt fra en spiller
func save_drawing(player_id: int, image: Image) -> void:
	var texture = ImageTexture.create_from_image(image)
	current_round_drawings[player_id] = texture

# Rydder alle tegninger i den aktuelle runde
func clear_drawings() -> void:
	current_round_drawings.clear()

# Nulstiller hele spillets tilstand ved genstart fra "Spil igen"
func reset_game_state() -> void:
	current_round = 1
	current_round_drawings.clear()
