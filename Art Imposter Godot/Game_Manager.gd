extends Node

var players: Array[PlayerData] = []


func _ready():

	create_test_players()


func create_test_players():

	for i in range(4):

		var player := PlayerData.new()

		player.nickname = "Player" + str(i + 1)

		player.avatar_id = i

		players.append(player)
