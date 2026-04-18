extends Node2D

var fireTime := 0.0
var gun: GunResource = load("res://guns/smg.tres")

func trace(a, b):
	var tracer = Line2D.new()
	tracer.antialiased = true
	tracer.z_index = 2
	tracer.default_color = Color8(255, 255, 255, 64)
	tracer.width = 2.0
	tracer.clear_points()
	tracer.add_point(a)
	tracer.add_point(b)
	get_tree().current_scene.add_child(tracer)

	var tracerTween = get_tree().create_tween()
	tracerTween.tween_property(tracer, "default_color", Color8(255, 255, 255, 0), 0.2)
	
	if tracer.default_color.a <= 0.1:
			tracer.queue_free()

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
	
	#print("dir:", str(direction.rotated(spreadRad)) + "\n" + str(result) + "\n" + str(query))
	
	if result:
		trace(start, result["position"])
		
		var hit = result["collider"]
		
		if hit.has_method("hurt"):
			hit.hurt(gun.damage)
	else:
		trace(start, end)

func tryShoot():
	var now = Time.get_ticks_msec() / 1000.0
	
	if now < fireTime:
		return
	
	shoot()
	fireTime = now + gun.rateOfFire

func _process(_delta: float) -> void:
	if (Input.is_action_just_pressed(get_parent().inputPrefix + "shoot") and gun.auto == false) or (Input.is_action_pressed(get_parent().inputPrefix + "shoot") and gun.auto == true):
		tryShoot()
