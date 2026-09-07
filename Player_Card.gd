extends Panel

@onready var nickname_label: Label = $Nickname
@onready var status_label: Label = $Status
@onready var avatar_texture: TextureRect = $Avatar


func setup(player: PlayerData) -> void:
	nickname_label.text = player.nickname

	if player.is_ready:
		status_label.text = "✅ Klar"
	else:
		status_label.text = "✏️ Tegner"

	load_avatar(player.avatar_id)


func load_avatar(id: int) -> void:
	var path := "res://avatars/avatar_%d.png" % id
	if ResourceLoader.exists(path):
		avatar_texture.texture = load(path)
