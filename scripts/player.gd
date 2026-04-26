extends CharacterBody2D

signal damaged(damage, hp)
signal death(murderer, victim, weapon)

var hp := 100.0

var maxSpeed = 105
const acceleration = 290.0
const friction = 8
var jumpSpeed = -230.0
# fuc kyou
const airFriction = 2
var maxWallJumps = 3
var gravity = 0.85

var facingDirection: Vector2
var yAim: int # 1 up 0 none -1 down
var aimingX: bool

var wallLock = 0.0
var wasOnFloor = false
var wallJumps = maxWallJumps
var wallJumped

@export var inputPrefix: String # p1- p2-

@onready var coyote: Timer = $coyoteTimer

func justSwapped():
	return Input.is_action_just_pressed(inputPrefix + "swap")

func teleportAndStop(pos: Vector2):
	global_position = pos
	velocity = Vector2.ZERO

func nudge(direction: Vector2, speed):
	velocity += -direction * speed
	
func hurt(opponentGun: GunResource):
	hp -= opponentGun.damage
	
	if hp <= 0.0:
		#print("man im dead " + inputPrefix)
		
		var otherPlayer = "player1"
		if self.name == "player1":
			otherPlayer = "player2"
		
		emit_signal("death", otherPlayer, self.name, opponentGun.displayName)
		queue_free()
	
	emit_signal("damaged", opponentGun.damage, hp)

func _physics_process(delta: float) -> void:
	# Get current ( last ) on-floor state and move
	wasOnFloor = is_on_floor()
	move_and_slide()
	
	#if velocity: print(velocity)
	
	print(wallLock)
	
	var onFloor = is_on_floor()
	var onWall = is_on_wall_only()
	
	# Start coyote jump timer
	if not onFloor:
		if wasOnFloor:
			coyote.start()
	
	# Jump from ground
	if Input.is_action_pressed(inputPrefix + "up") and onFloor:
		velocity.y = jumpSpeed
	if Input.is_action_just_pressed(inputPrefix + "up") and not coyote.is_stopped():
		velocity.y = jumpSpeed
	
	# Reset walljump limit
	if onFloor:
		wallJumps = maxWallJumps
	
	# Apply gravity
	velocity += get_gravity() * delta * gravity
	
	# Walljumps ( hell ) ( urath )
	if onWall and wallJumps and Input.is_action_just_pressed(inputPrefix + "up"):
		var wjNormal = get_wall_normal().x
		var doWallBounce = Input.get_axis(inputPrefix + "left", inputPrefix + "right")
		
		# Customizable settings for walljumps:
		var wSpeedX = 150
		var wSpeedXBounce = 180
		var wSpeedY = -300
		var wSpeedYBounce = -50
		# ------------------------------------
		
		if doWallBounce:
			wSpeedX = wSpeedXBounce
			wSpeedY = wSpeedYBounce
		
		velocity.x += wSpeedX * wjNormal
		velocity.y += wSpeedY
		
		wallJumps -= 1
		wallLock = 0.12
		wallJumped = true
	
	# X Movement
	var direction := Input.get_axis(inputPrefix + "left", inputPrefix + "right")
	
	if direction and not wallJumped and wallLock <= 0:
		var targetSpeed = direction * maxSpeed
		velocity.x = move_toward(velocity.x, targetSpeed, acceleration * delta)
	else:
		if onFloor:
			velocity.x = move_toward(velocity.x, 0, friction)
		else:
			velocity.x = move_toward(velocity.x, 0, airFriction)
	
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
	
