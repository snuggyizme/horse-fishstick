extends Node2D

@export var gun: GunResource

var playersInRange = []

func _ready() -> void:
	updateSprite()

func updateSprite():
	if gun and gun.visual:
		if gun.visual.get_node("gun") is Sprite2D:
			var instance = gun.visual.instantiate()
			var gunSprite = instance.get_node("gun")
			if instance.has_node("decals"):
				for decal in instance.get_node("decals").get_children():
					var decalSprite = Sprite2D.new()
					decalSprite.texture = decal.texture
					decalSprite.name = "decal (" +	gun.displayName + ") " + str(randi_range(100, 999))
					self.add_child(decalSprite)
			$gun.texture = gunSprite.texture
			instance.queue_free()
		elif gun.visual.get_node("gun") is AnimatedSprite2D:
			var instance = gun.visual.instantiate()
			var gunSprite = instance #aaa
	
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
	player.get_node("gunController").setGun(gun)
