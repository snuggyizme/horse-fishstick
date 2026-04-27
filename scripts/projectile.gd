extends CharacterBody2D

signal onHit(gunUsed, normal, pos)

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
	
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		var collider = collision.get_collider()
		if collider.has_method("hurt"):
			if collider != playerOwner:
				collider.hurt(gunResource)
				onHit.emit(gunResource, collision.get_normal(), global_position)
				# spawn vfx? i dont awnt to draw explosions (~~i do but it would suck~~) hehe ye i did it
				queue_free()
		else:
			if bounces > 0:
				velocity = velocity.bounce(collision.get_normal())
				bounces -= 1
			else:
				onHit.emit(gunResource, collision.get_normal(), global_position)
				queue_free()
