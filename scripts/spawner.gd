extends Node2D

@export var gun: GunResource

var playersInRange = []

func _ready() -> void:
	updateSprite()

func updateSprite():
	if gun and gun.visual:
		var instance = gun.visual.instantiate()
		var gunSprite = instance.get_node_or_null("gun")
		if gunSprite == null:
			print("You forgot a gun in the visual: ", gun.visual)
			return
		if instance.has_node("decals") and false: # decals off, i dont think we should have them
			for decal in instance.get_node("decals").get_children():
				var decalSprite
				
				if decal is Sprite2D:
					decalSprite = Sprite2D.new()
					decalSprite.texture = decal.texture
				
				elif decal is AnimatedSprite2D:
					decalSprite = AnimatedSprite2D.new()
					var spriteFrames = SpriteFrames.new()
					spriteFrames.add_animation("default")
					for frame in range(decal.sprite_frames.get_frame_count("default")):
						spriteFrames.add_frame(
							"default",
							decal.sprite_frames.get_frame_texture("default", frame),
							decal.sprite_frames.get_frame_duration("default", frame)
						)
					decalSprite.sprite_frames = spriteFrames
					decalSprite.autoplay = "default"
				
				decalSprite.name = decal.name
				self.add_child(decalSprite)
		if gunSprite is AnimatedSprite2D:
			var gunDisplay = AnimatedSprite2D.new()
			gunDisplay.sprite_frames = SpriteFrames.new()
			gunDisplay.autoplay = "default"
			for frame in range(gunSprite.sprite_frames.get_frame_count("default")):
				gunDisplay.sprite_frames.add_frame(
					"default",
					gunSprite.sprite_frames.get_frame_texture("default", frame),
					gunSprite.sprite_frames.get_frame_duration("default", frame)
				)
			gunDisplay.name = "display_gun"
			add_child(gunDisplay)
		else:
			var gunDisplay = Sprite2D.new()
			gunDisplay.texture = gunSprite.texture
			gunDisplay.name = "display_gun"
			add_child(gunDisplay)
			
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
	player.get_node("gunController").setGun(gun)
