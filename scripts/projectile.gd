extends CharacterBody2D

signal onHit(gunUsed)

var gravity := 0.0
var bounces := 0

var gunResource

var playerOwner # set by guncontroller.gd on instantiate

func setType(gun: GunResource):
	gravity = gun.projectileDrop
	bounces = gun.projectileBounces
	self.gunResource = gun

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	look_at(global_position + velocity)
	
	move_and_slide()
	if get_slide_collision_count() > 0:
		for i in range(get_slide_collision_count()):
			var collider = get_slide_collision(i).get_collider()
			print(collider, playerOwner)
			if collider.has_method("hurt"):
				if collider == playerOwner:
					continue
				collider.hurt(gunResource.damage)
				onHit.emit(gunResource)
				# spawn vfx? i dont awnt to draw explosions (~~i do but it would suck~~)
				queue_free()
			else:
				if bounces > 0:
					velocity = velocity.bounce(collider.get_normal())
					bounces -= 1
				else:
					onHit.emit(gunResource)
					queue_free()
