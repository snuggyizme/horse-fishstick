extends Node

signal playerReady(p1, p2)

var p1
var p2

var ui

const halfScreen = Vector2(432.0 / 2.0, 243.0 / 2.0)

const maps = [
	{"name": "hallway_01", "group": "hallway"},
	{"name": "hallway_02", "group": "hallway"},
	{"name": "hallway_03", "group": "hallway"},
	{"name": "hallway_04", "group": "hallway"},
	
	{"name": "palace_01", "group": "palace"},
	{"name": "palace_02", "group": "palace"},
	{"name": "palace_03", "group": "palace"},
	
	{"name": "chamber_01", "group": "chamber"},
	{"name": "chamber_02", "group": "chamber"},
	
	{"name": "temple_01", "group": "temple"},
	
	{"name": "store_01", "group": "store"},
	
	{"name": "openair_01", "group": "openair"},
	{"name": "openair_02", "group": "openair"},
	
	{"name": "parliament_01", "group": "parliament"},
	{"name": "parliament_02", "group": "parliament"},
	
	{"name": "truth_01", "group": "truth"},
	
]

var lastMaps = []

func loadMap(mapname: String):
	var gameworld = get_tree().current_scene.get_node("gameworld")
	
	
	for innocentChild in gameworld.get_children():
		innocentChild.queue_free()
		
	var mapPacked = load("res://scenes/maps/" + mapname + ".tscn")
	var map = mapPacked.instantiate()
	gameworld.add_child(map)
	
	# getting and/or respawning players :
	
	var playerScene = load("res://scenes/player.tscn")
	var playerFolder = get_tree().current_scene.get_node("players")
	
	if playerFolder.has_node("player1"):
		p1 = playerFolder.get_node("player1")
	else:
		p1 = playerScene.instantiate()
		p1.inputPrefix = "p1-"
		p1.name = "player1"
		playerFolder.add_child(p1)
		p1.displayUsername()
	
	if playerFolder.has_node("player2"):
		p2 = playerFolder.get_node("player2")
	else:
		p2 = playerScene.instantiate()
		p2.inputPrefix = "p2-"
		p2.name = "player2"
		playerFolder.add_child(p2)
		p2.displayUsername()
	
	var spawnA = map.get_node("playerspawns").get_node("a")
	var spawnB = map.get_node("playerspawns").get_node("b")
	if randi_range(0, 1):
		p1.teleportAndStop(spawnA.global_position - halfScreen)
		p2.teleportAndStop(spawnB.global_position - halfScreen)
	else:
		p1.teleportAndStop(spawnB.global_position - halfScreen)
		p2.teleportAndStop(spawnA.global_position - halfScreen)
	
	p1.hp = 100
	p2.hp = 100
		
	p1.displayUsername()
	p2.displayUsername()

func _ready():
	pickMap()
	
func pickMap():
	var skip: bool
	if len(_getAllMapNames(maps)) < len(lastMaps):
		skip = true
	else:
		skip = false
	
	if len(lastMaps) > 2:
		lastMaps.remove_at(0)
		
	var pick = maps.pick_random()["name"]
	while pick in lastMaps and not skip:
		pick = maps.pick_random()["name"]
	
	while ui == null:
		await get_tree().process_frame
		
	await get_tree().process_frame # just in fucking case i hate fucking fuckign hate fuck
	loadMap(pick)
	lastMaps.append(pick)
	playerReady.emit(p1, p2)
		
func _getAllMapNames(m: Array):
	var export = []
	for i in m:
		export.append(i["name"])
	return export
