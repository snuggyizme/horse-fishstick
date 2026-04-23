extends Node2D

var fireTime := 0.0
var burstFireTime := 0.0
var gun: GunResource = load("res://guns/zapper.tres")

var visual: Node2D
var muzzle

var facingDirection = "right"
var gunPos

var burstAmmo: int
var ammo: int

var holyFuckTooManyAimingVariables

func _ready():
	setGun(gun)

func setGun(newGun: GunResource):
	gun = newGun
	
	if visual:
		visual.queue_free()
		
	visual = gun.visual.instantiate()
	add_child(visual)
	
	muzzle = visual.get_node("muzzle")
	gunPos = visual.position
	
	burstAmmo = gun.burstSize
	ammo = gun.ammo

func trace(a, b, width=2.0):
	var fadeOut
	
	var tracer = Line2D.new()
	tracer.antialiased = true
	tracer.z_index = 2
	if gun.overrideTracers:
		tracer.default_color = Color(gun.tracerColour)
		fadeOut = Color.html(gun.tracerColourFade + "00")
	else:
		tracer.default_color = Color8(255, 255, 255, 64)
		fadeOut = Color8(255, 255, 255, 0)
	tracer.width = width
	tracer.clear_points()
	tracer.add_point(a)
	tracer.add_point(b)
	get_tree().current_scene.add_child(tracer)
	
	var tracerTween = get_tree().create_tween()
	tracerTween.tween_property(
		tracer,
		"default_color",
		fadeOut,
		0.2
	)
	tracerTween.finished.connect(func(): tracer.queue_free())

func shoot():
	var spreadRad = deg_to_rad(randf_range(-gun.spread, gun.spread))
	
	var start = muzzle.global_position
	var direction = get_parent().facingDirection
	if get_parent().yAim != 0:
		direction = holyFuckTooManyAimingVariables
	var end = start + direction.rotated(spreadRad) * gun.rangeLimit
	
	get_parent().nudge(holyFuckTooManyAimingVariables, gun.recoil * 100)
	#get_parent().nudge(Vector2.LEFT, 350)
	
	var spaceState = get_world_2d().direct_space_state
	var muzzleQuery = PhysicsPointQueryParameters2D.new()
	muzzleQuery.position = start
	muzzleQuery.collide_with_areas = true
	muzzleQuery.collide_with_bodies = true
	muzzleQuery.exclude = [get_parent()]
	muzzleQuery.collision_mask = 1
	
	var muzzleResults = spaceState.intersect_point(muzzleQuery)
	if muzzleResults.size() > 0:
		for hit in muzzleResults:
			var collider = hit.collider
			
			if collider.has_method("hurt"):
				collider.hurt(gun.damage)
				collider.nudge(-direction, gun.knockback * 50)
				
		#print("point blank")
		return
	
	if gun.useShapeCast:
		var shapeQuery = ShapeCast2D.new()
		add_child(shapeQuery)
		
		var shape = CircleShape2D.new()
		shape.radius = gun.LaserSize
		shapeQuery.shape = shape
		
		shapeQuery.target_position = end
		shapeQuery.enabled = true
		shapeQuery.collision_mask = 1
		shapeQuery.exclude_parent = true
		
		shapeQuery.force_shapecast_update()
		
		if shapeQuery.is_colliding():
			var hitCount = shapeQuery.get_collision_count()
			
			for hit in range(hitCount):
				var collider = shapeQuery.get_collider(hit)
				if collider.has_method("hurt"):
					collider.hurt(gun.damage)
					collider.nudge(-direction, gun.knockback * 50)
				
				trace(start, end, 6)
		return
	
	var query = PhysicsRayQueryParameters2D.create(start, end)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.exclude = [get_parent()]
	query.hit_from_inside = true
	query.collision_mask = 1
	
	var result = spaceState.intersect_ray(query)
	
	flash(start, facingDirection)
	
	#print("dir:", str(direction.rotated(spreadRad)) + "\n" + str(result) + "\n" + str(query))
	
	if result:
		trace(start, result["position"])
		
		var hit = result["collider"]
		
		if hit.has_method("hurt"):
			hit.hurt(gun.damage)
			hit.nudge(-direction, gun.knockback * 50)
	else:
		trace(start, end)

func tryShoot():
	var now = Time.get_ticks_msec() / 1000.0
	
	if gun.isBurst and not gun.doBullertsPerShotWithBurstAmmo: # burst and not shotgun
		if burstAmmo > 0 and now < burstFireTime:
			return
		
		if burstAmmo <= 0:
			if now < fireTime:
				return
			
			var loadAmount = min(gun.burstSize, ammo)
			burstAmmo = loadAmount
			ammo -= loadAmount
			if visual.has_method("onRefillBurstAmmo"):
				visual.onRefillBurstAmmo()
			
		if burstAmmo <= 0:
			print("no ammo")
			if visual.has_method("onDryAmmo"):
				visual.onDryAmmo()
			return # empty mag die die die uh die
		
		shoot()
		if visual.has_method("onShoot"):
			visual.onShoot()
		burstAmmo -= 1
		
		burstFireTime = now + gun.burstRate
		fireTime = now + gun.rateOfFire
		
		return
	elif gun.isBurst and gun.doBullertsPerShotWithBurstAmmo: # burst shotgun (reload needed)
		if burstAmmo > 0 and now < fireTime:
			return
		if burstAmmo <= 0:
			if now < fireTime:
				return
			
			var loadAmount = min(gun.burstSize, ammo)
			burstAmmo = loadAmount
			ammo -= loadAmount
			if visual.has_method("onRefillBurstAmmo"):
				visual.onRefillBurstAmmo()
		
		if ammo <= 0:
			print("no ammo")
			if visual.has_method("onDryAmmo"):
				visual.onDryAmmo()
			return
		
		for pellet in range(gun.bulletsPerShot):
			shoot()
			if visual.has_method("onShoot"):
				visual.onShoot()
			burstAmmo -= 1
		fireTime = now + gun.rateOfFire
	if now < fireTime:
		return
		
	if ammo <= 0:
		print("no ammo")
		if visual.has_method("onDryAmmo"):
				visual.onDryAmmo()
		return
	
	ammo -= 1
	shoot()
	
	if visual.has_method("onShoot"):
		visual.onShoot()
	
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
	if not get_parent().aimingX:
		if yAim > 0:
			visual.rotation_degrees = 90
			holyFuckTooManyAimingVariables = Vector2.DOWN
		elif yAim < 0:
			visual.rotation_degrees = -90
			holyFuckTooManyAimingVariables = Vector2.UP
		else:
			visual.rotation_degrees = 0
			holyFuckTooManyAimingVariables = get_parent().facingDirection
	else:
		visual.rotation_degrees = 0
		holyFuckTooManyAimingVariables = get_parent().facingDirection
	
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
