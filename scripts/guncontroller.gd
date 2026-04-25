extends Node2D

var fireTime := 0.0
var burstFireTime := 0.0
var gun: GunResource = load("res://guns/hk169.tres")

var visual: Node2D
var muzzle
var projectileVisualScene: PackedScene

var facingDirection = "right"
var gunPos

var burstAmmo: int
var ammo: int

var holyFuckTooManyAimingVariables

var moveTracer

var sounds = {
	"shot": [
		"light", # temp for index
		"medium", #temp for index
		load("res://assets/sfx/weapons/heavyGunshot.ogg"),
		"shotty light", # temp index
		load("res://assets/sfx/weapons/shotgunHeavy.ogg")
	],
	"kaping": load("res://assets/sfx/weapons/kaping.ogg")
}

@onready var excludes = [
	get_parent(),
	get_node("../headhurtbox"), get_node("../headhurtbox/head"),
	get_node("../bodyhurtbox"), get_node("../bodyhurtbox/body"),
]

var projectileScene = load("res://scenes/projectile_base.tscn")

func _ready():
	setGun(gun)

func _onProjectileHit(gunUsed):
	pass

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
	
	if gun.projectileVisual:
		projectileVisualScene = gun.projectileVisual

func trace(a, b, width=2.0):
	var fadeOut
	var fadeTime = 0.2
	
	var tracer = Line2D.new()
	tracer.antialiased = true
	tracer.z_index = 2
	if gun.overrideTracers:
		tracer.default_color = Color(gun.tracerColour)
		fadeOut = Color.html(gun.tracerColourFade + "00")
	else:
		tracer.default_color = Color8(255, 255, 255, 64)
		fadeOut = Color8(255, 200, 200, 0)
	if gun.doTracersGlow:
		tracer.default_color = tracer.default_color.blend(Color(2, 2, 2))
	if gun.overrideFade:
		fadeTime = gun.fadeTime
	
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
		fadeTime
	)
	tracerTween.finished.connect(func(): tracer.queue_free())

func kapingIt():
	var kapinger = AudioStreamPlayer2D.new()
	kapinger.stream = sounds["kaping"]
	add_child(kapinger)
	await get_tree().create_timer(0.4).timeout
	kapinger.play()
	
	if visual.has_method("ejectShell"):
		visual.ejectShell()

func shootSoundSpecific():
	var soundDevice = AudioStreamPlayer2D.new()
	soundDevice.stream = sounds["shot"][gun.shootSound]
	add_child(soundDevice)
	soundDevice.play()

func shootSound():
	if gun.shootSound:
		shootSoundSpecific()
		
	if gun.doKaping:
		kapingIt()

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
	muzzleQuery.exclude = excludes
	muzzleQuery.collision_mask = 1
	
	var muzzleResults = spaceState.intersect_point(muzzleQuery)
	if muzzleResults.size() > 0:
		for hit in muzzleResults:
			var collider = hit.collider
			
			if collider in excludes:
				print("pah")
				continue
			
			if collider.has_method("hurt"):
				collider.hurt(gun.damage)
				collider.nudge(-direction, gun.knockback * 50)
				
				print("point blank")
				flash(start, holyFuckTooManyAimingVariables)
				return
	
	if gun.isProjectile: # aaaaa proejctile wepaonry gona comit first olol
		var projectile = projectileScene.instantiate()
		projectile.global_position = muzzle.global_position
		projectile.velocity = (gun.projectileSpeed * holyFuckTooManyAimingVariables).rotated(spreadRad)
		projectile.setType(gun)
		projectile.playerOwner = get_parent()
		projectile.add_child(projectileVisualScene.instantiate())
		projectile.onHit.connect(_onProjectileHit)
		get_tree().current_scene.add_child(projectile)
	
	if gun.useShapeCast:
		var shape = CircleShape2D.new()
		shape.radius = gun.LaserSize / 2.0 # laserSize is circumf
		
		@warning_ignore("confusable_local_declaration")
		var query = PhysicsShapeQueryParameters2D.new()
		query.shape = shape
		query.transform = Transform2D(0, start)
		query.motion = direction.rotated(spreadRad) * gun.rangeLimit
		
		query.collide_with_areas = true
		query.collide_with_bodies = true
		query.exclude = excludes
		query.collision_mask = 1
		
		var results = spaceState.intersect_shape(query)
		
		if results.size() > 0:
			for result in results:
				var collider = result.collider
				if collider.has_method("hurt"):
					collider.hurt(gun.damage)
					collider.nudge(-direction, gun.knockback * 50)
		
		trace(start, end, gun.LaserSize)
		return
	
	var query = PhysicsRayQueryParameters2D.create(start, end)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.exclude = excludes
	query.hit_from_inside = true
	query.collision_mask = 1
	
	var result = spaceState.intersect_ray(query)
	
	flash(start, holyFuckTooManyAimingVariables)
	
	#print("dir:", str(direction.rotated(spreadRad)) + "\n" + str(result) + "\n" + str(query))
	
	if result:
		trace(start, result["position"])
		
		var hit = result["collider"]
		
		#print("hit:")
		#print(hit)
		#print(hit.get_class())
		#print(hit.name)
		
		if hit.has_method("hurt"):
			print("hit player")
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
		
		print("shot - source: burst gun ", gun.displayName)
		shoot()
		shootSound()
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
		
		if ammo <= 0: # burst count ran out
			print("no ammo")
			if visual.has_method("onDryAmmo"):
				visual.onDryAmmo()
			return
		
		print("shot - source: burst shotgun ", gun.displayName)
		for pellet in range(gun.bulletsPerShot):
			shoot()
			
			if visual.has_method("onShoot"):
				visual.onShoot()
			burstAmmo -= 1
		shootSound()
		fireTime = now + gun.rateOfFire
		
	# normal gun or normal shotgun
	if now < fireTime:
		return
		
	if ammo <= 0:
		print("no ammo")
		if visual.has_method("onDryAmmo"):
			visual.onDryAmmo()
		return
	
	ammo -= 1
	
	if not gun.doBullertsPerShotWithBurstAmmo:
		print("shot - source: gun ", gun.displayName)
		shoot()
		shootSound()
	else: # coming back on this HOW THE FUCK DOES THIS WORK
		for pellet in range(gun.bulletsPerShot):
			shoot()
		print("shot - source: shotgun ", gun.displayName)
		shootSound()
	
	if visual.has_method("onShoot"):
		visual.onShoot()
	
	fireTime = now + gun.rateOfFire
		
func flash(pos, dir):
	var mFlash = Sprite2D.new()
	mFlash.set_texture(load("res://assets/sprites/muzzle-flash.png"))
	mFlash.global_position = pos
	match dir:
		Vector2.LEFT:
			mFlash.rotation_degrees = 180
		Vector2.RIGHT:
			mFlash.rotation_degrees = 0
		Vector2.DOWN:
			mFlash.rotation_degrees = 90
		Vector2.UP:
			mFlash.rotation_degrees = 270
	
	get_tree().current_scene.add_child(mFlash)
	
	var flashTween = get_tree().create_tween()
	flashTween.tween_property(mFlash, "modulate:a", 0.0, 0.15)
	flashTween.tween_callback(mFlash.queue_free)
	

func _process(_delta: float) -> void:
	var yAim = get_parent().yAim
	var fD = get_parent().facingDirection
	if not get_parent().aimingX:
		if yAim > 0:
			if fD == Vector2.LEFT:
				visual.rotation_degrees = -90
			else:
				visual.rotation_degrees = 90
			holyFuckTooManyAimingVariables = Vector2.DOWN
		elif yAim < 0:
			if fD == Vector2.LEFT:
				visual.rotation_degrees = 90
			else:
				visual.rotation_degrees = -90
			holyFuckTooManyAimingVariables = Vector2.UP
		else:
			visual.rotation_degrees = 0
			holyFuckTooManyAimingVariables = get_parent().facingDirection
	else:
		visual.rotation_degrees = 0
		holyFuckTooManyAimingVariables = get_parent().facingDirection
	
	if (Input.is_action_just_pressed(get_parent().inputPrefix + "shoot") and gun.auto == false) or (Input.is_action_pressed(get_parent().inputPrefix + "shoot") and gun.auto == true):
		tryShoot()
	visual.scale.x = 1
	visual.position = gunPos
	if get_parent().facingDirection == Vector2.LEFT:
		visual.scale.x = -1
		#visual.position = -gunPos
		
