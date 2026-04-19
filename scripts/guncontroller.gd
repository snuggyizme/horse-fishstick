extends Node2D

var fireTime := 0.0
var burstFireTime := 0.0
var gun: GunResource = load("res://guns/smg.tres")

var visual
var muzzle

var facingDirection = "right"
var gunPos

var burstAmmo: int
var ammo: int

func _ready():
	setGun(gun)

func setGun(newGun: GunResource):
	gun = newGun
	
	if visual:
		visual.queue_free()
		
	visual = gun.visual.instantiate()
	add_child(visual)
	
	muzzle = visual.get_node("muzzle")
	gunPos = visual.global_position
	
	burstAmmo = gun.burstSize
	ammo = gun.ammo

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
	tracerTween.finished.connect(func(): tracer.queue_free())

func shoot():
	var spreadRad = deg_to_rad(randf_range(-gun.spread, gun.spread))
	
	var start = muzzle.global_position
	var direction = get_parent().facingDirection
	if get_parent().yAim != 0:
		direction = Vector2(0.0, float(get_parent().yAim))
	var end = start + direction.rotated(spreadRad) * gun.rangeLimit
	
	var spaceState = get_world_2d().direct_space_state
	
	var query = PhysicsRayQueryParameters2D.create(start, end)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.exclude = [get_parent()]
	
	var result = spaceState.intersect_ray(query)
	
	flash(start, facingDirection)
	
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
	
	if gun.isBurst:
		if burstAmmo > 0 and now < burstFireTime:
			return
		
		if burstAmmo <= 0:
			if now < fireTime:
				return
			
			var loadAmount = min(gun.burstSize, ammo)
			burstAmmo = loadAmount
			ammo -= loadAmount
			
		if burstAmmo <= 0:
			print("no ammo")
			return # empty mag die die die uh die
		
		shoot()
		burstAmmo -= 1
		
		burstFireTime = now + gun.burstRate
		fireTime = now + gun.rateOfFire
		
		return
	if now < fireTime:
		return
		
	if ammo <= 0:
		print("no ammo")
		return
	
	ammo -= 1
	shoot()
	fireTime = now + gun.rateOfFire
		
	
func flash(pos, dir):
	var mFlash = Sprite2D.new()
	mFlash.set_texture(load("res://assets/sprites/muzzle-flash.png"))
	mFlash.global_position = pos
	match dir:
		"left":
			mFlash.flip_h = true
		"right":
			mFlash.flip_h = false
	
	get_tree().current_scene.add_child(mFlash)
	
	var flashTween = get_tree().create_tween()
	flashTween.tween_property(mFlash, "modulate:a", 0.0, 0.15)
	flashTween.tween_callback(mFlash.queue_free)
	

func _process(_delta: float) -> void:
	var yAim = get_parent().yAim
	if yAim > 0:
		visual.rotation = 90
	elif yAim < 0:
		visual.rotation = -90
	else:
		visual.rotation = 0
	
	if facingDirection == "left":
		visual.rotation = -visual.rotation
		
	if (Input.is_action_just_pressed(get_parent().inputPrefix + "shoot") and gun.auto == false) or (Input.is_action_pressed(get_parent().inputPrefix + "shoot") and gun.auto == true):
		tryShoot()
		
	if get_parent().facingDirection == Vector2.RIGHT and facingDirection == "left":
		facingDirection = "right"
		visual.scale.x = 1
		visual.position = gunPos
	elif get_parent().facingDirection == Vector2.LEFT and facingDirection == "right":
		facingDirection = "left"
		visual.scale.x = -1
		visual.position = -gunPos
