extends Node2D

@export var gun: GunResource

var playersInRange = []

func _ready() -> void:
	updateSprite()

func updateSprite():
	if gun and gun.visual:
		var instance = gun.visual.instantiate()
		var gunSprite = instance.get_node("gun")
		$gun.texture = gunSprite.texture
		instance.queue_free()
	
func bodyEntered(body: Node2D) -> void:
	if body.is_in_group("players") and body not in playersInRange:
		playersInRange.append(body)

func bodyExited(body: Node2D) -> void:
	if body.is_in_group("players"):
		playersInRange.erase(body)

func _process(_delta):
	for player in playersInRange:
		if player.justSwapped() and is_instance_valid(player):
			swapGuns(player)

func swapGuns(player):
	var oldGun = player.get_node("gunController").gun
	player.get_node("gunController").setGun(gun)
