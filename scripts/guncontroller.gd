extends Node2D

var fireTime := 0.0
var gun: GunResource = load("res://guns/smg.tres")

func shoot():
	var spreadRad = deg_to_rad(randf_range(-gun.spread, gun.spread))
	
	var start = global_position
	var direction = get_parent().facingDirection
	var end = start + direction.rotated(spreadRad) * gun.rangeLimit
	
	var spaceState = get_world_2d().direct_space_state
	
	var query = PhysicsRayQueryParameters2D.create(start, end)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var result = spaceState.intersect_ray(query)
	
	
	
	if result:
		var tracer = Line2D.new()
		tracer.antialiased = true
		tracer.z_index = 2
		tracer.default_color = Color8(255, 255, 255, 64)
		tracer.width = 2.0
		tracer.clear_points()
		tracer.add_point(start)
		tracer.add_point(result["position"])
		get_tree().current_scene.add_child(tracer)
	
		var tracerTween = get_tree().create_tween()
		tracerTween.tween_property(tracer, "default_color", Color8(255, 255, 255, 0), 0.2)
		
		var hit = result["collider"]
		
		if hit.has_method("hurt"):
			hit.hurt(gun.damage)
			print("boy is dead " + str(gun.damage) + " " + str(hit.hp))

func tryShoot():
	var now = Time.get_ticks_msec() / 1000.0
	
	if now < fireTime:
		return
	
	shoot()
	fireTime = now + gun.rateOfFire

func _process(_delta: float) -> void:
	if (Input.is_action_just_pressed(get_parent().inputPrefix + "shoot") and gun.auto == false) or (Input.is_action_pressed(get_parent().inputPrefix + "shoot") and gun.auto == true):
		tryShoot()
