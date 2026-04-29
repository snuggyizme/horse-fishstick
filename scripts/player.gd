extends CharacterBody2D

signal damaged(damage, hp)
signal death(murderer, victim, weapon)

var hp := 100.0

const maxSpeed = 105
const acceleration = 290.0
const friction = 8
const jumpSpeed = -250.0
# fuc kyou
const airFriction = 2
const maxWallJumps = 3
const gravity = 0.85
const dashSpeed = 1.8
const airBoost = 2.5 # boost to accel when airborne. air control

var facingDirection: Vector2
var yAim: int # 1 up 0 none -1 down
var aimingX: bool

var wallLock = 0.0
var wasOnFloor = false
var wallJumps = maxWallJumps
var wallJumped

var bounceHit := false
var bounceNormal := Vector2.ZERO
var bounceLock := 0.0

const comboTimeout = 0.3
const maxCombo = 2

var lastKeyDelta = 0
var keyCombo = []

var doHeavyFriction := 0.0
var alreadyDashing := false

@export var inputPrefix: String # p1- p2-

@onready var coyote: Timer = $coyoteTimer
@onready var username: Label = $Label

const dashInput = {
	"p1-":
		{
			"left": [65, 65],
			"right": [68, 68],
		},
	"p2-":
		{
			"left": [74, 74],
			"right": [76, 76],
		}
}

func displayUsername():
	username.modulate = Color(1, 1, 1, 1)
	
	var nameTween = create_tween()
	nameTween.tween_property(username, "modulate:a", 0, 1.1)

func justSwapped():
	return Input.is_action_just_pressed(inputPrefix + "swap")
	
func teleportAndStop(pos: Vector2):
	global_position = pos
	velocity = Vector2.ZERO

func nudge(direction: Vector2, speed):
	velocity += -direction * speed

func checkDeath(opponentGun):
	if hp <= 0.0:
		#print("man im dead " + inputPrefix)
		
		var otherPlayer = "player1"
		if self.name == "player1":
			otherPlayer = "player2"
		
		emit_signal("death", otherPlayer, self.name, opponentGun.displayName)
		queue_free()
	
	emit_signal("damaged", opponentGun.damage, hp)

func hurtDamage(dmg: float, gun):
	hp -= dmg
	
	checkDeath(gun)

func hurt(opponentGun: GunResource):
	hp -= opponentGun.damage
	
	checkDeath(opponentGun)

func _input(event):
	if event is InputEventKey and !event.is_echo() and event.pressed:
		if not alreadyDashing:
			if lastKeyDelta > comboTimeout:
				keyCombo = []
			
			keyCombo.append(event.keycode)
			if keyCombo.size() > maxCombo:
				keyCombo.pop_front()
			
			lastKeyDelta = 0
			#print(keyCombo)

func heavyFriction(d):
	var frictionHeavy = 34
	var airFrictionHeavy = 19
	
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0, d * frictionHeavy)
	else:
		velocity.x = move_toward(velocity.x, 0, d * airFrictionHeavy)
	
	#print("Heavy bubbles")

func _physics_process(delta: float) -> void:
	lastKeyDelta += delta
	# Get current ( last ) on-floor state
	wasOnFloor = is_on_floor()
	
	# Move
	var preVelocity = velocity
	move_and_slide()
	
	# Is it bouncey
	if get_slide_collision_count():
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			
			if collider:
				if collider.is_in_group("bouncey"):
					#velocity = velocity.bounce(collision.get_normal()) * 1.5
					
					bounceHit = true
					bounceNormal = collision.get_normal().normalized()
					if abs(bounceNormal.x) < 0.01:
						bounceNormal.x = 0
					if abs(bounceNormal.y) < 0.01:
						bounceNormal.y = 0
	
	#if velocity: print(velocity)
	
	#print(wallLock)
	
	var onFloor = is_on_floor()
	var onWall = is_on_wall_only()
	
	# Start coyote jump timer
	if not onFloor:
		if wasOnFloor:
			coyote.start()
	
	# Jump from ground if not right after a bouncepad
	if bounceLock <= 0:
		if Input.is_action_pressed(inputPrefix + "up") and onFloor:
			velocity.y = jumpSpeed
		if Input.is_action_just_pressed(inputPrefix + "up") and not coyote.is_stopped():
			velocity.y = jumpSpeed
	
	# Reset walljump limit
	if onFloor:
		wallJumps = maxWallJumps
		
	
	# Apply gravity
	if bounceLock <= 0:
		velocity += get_gravity() * delta * gravity
	
	# Right after dash, slow down again:
	if doHeavyFriction > 0:
		heavyFriction(delta)
		doHeavyFriction -= delta
	
	# Walljumps ( hell ) ( urath )
	if onWall and wallJumps and Input.is_action_just_pressed(inputPrefix + "up"):
		var wjNormal = get_wall_normal().x
		var doWallBounce = Input.get_axis(inputPrefix + "left", inputPrefix + "right")
		
		# Customizable settings for walljumps:
		var wSpeedX = 240
		var wSpeedXBounce = 40
		var wSpeedY = -200
		var wSpeedYBounce = -390
		# ------------------------------------
		
		if doWallBounce:
			wSpeedX = wSpeedXBounce
			wSpeedY = wSpeedYBounce
			wallJumps -= 1 # whatever goes up must go down
		
		velocity.x = wSpeedX * wjNormal
		velocity.y = wSpeedY
		
		wallLock = 0.12
		wallJumped = true
		
	# X Movement
	var direction := Input.get_axis(inputPrefix + "left", inputPrefix + "right")
	
	if direction and not wallJumped and wallLock <= 0:
		var targetSpeed
		if keyCombo == dashInput[inputPrefix]["left"] and not alreadyDashing:
			targetSpeed = maxSpeed * -dashSpeed
			velocity.x = move_toward(velocity.x, targetSpeed, acceleration)
			alreadyDashing = true
			doHeavyFriction = 0.2
		elif keyCombo == dashInput[inputPrefix]["right"] and not alreadyDashing:
			targetSpeed = maxSpeed * dashSpeed
			velocity.x = move_toward(velocity.x, targetSpeed, acceleration)
			doHeavyFriction = 0.2
			alreadyDashing = true
		else:
			targetSpeed = direction * maxSpeed
			if not onFloor:
				velocity.x = move_toward(velocity.x, targetSpeed, acceleration * airBoost * delta)
			else:
				velocity.x = move_toward(velocity.x, targetSpeed, acceleration * delta)
	else:
		if onFloor:
			velocity.x = move_toward(velocity.x, 0, friction)
		else:
			velocity.x = move_toward(velocity.x, 0, airFriction)
	
	# Allow dashing again
	if not direction:
		alreadyDashing = false
	
	# Allow another walljump
	if wallJumped:
		wallJumped = false
	if wallLock > 0:
		wallLock -= delta
	
	# Aiming
	if Input.is_action_pressed(inputPrefix + "left"):
		facingDirection = Vector2.LEFT
		aimingX = true
	elif Input.is_action_pressed(inputPrefix + "right"):
		facingDirection = Vector2.RIGHT
		aimingX = true
	else:
		aimingX = false
		
	if Input.is_action_pressed(inputPrefix + "up"):
		yAim = -1
	elif Input.is_action_pressed(inputPrefix + "down"):
		yAim = 1
	else:
		yAim = 0
	
	if bounceLock > 0:
		bounceLock -= delta
	
	if bounceHit:
		var v = preVelocity
		var f = abs(preVelocity.y)
		var n = bounceNormal

		velocity = (v - 2.0 * v.dot(n) * n) * (1.0 + (f / 300.0)) * 0.30
		bounceLock = 0.14
		bounceHit = false
		#print(bounceNormal)
	
