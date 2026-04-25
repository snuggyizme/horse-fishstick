extends CharacterBody2D

signal onHit

var gravity := 0.0
var bounces := 0

var gunResource

func setType(gun: GunResource):
	gravity = gun.projectileDrop
	bounces = gun.projectileBounces
	self.gunResource = gun

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	look_at(global_position + velocity)
	
	var _x = move_and_slide()
	if get_slide_collision_count() > 0:
		var collision = get_slide_collision(0)
		
		if bounces > 0:
			velocity = velocity.bounce(collision.get_normal())
		else:
			onHit.emit(gunResource)
			queue_free()
