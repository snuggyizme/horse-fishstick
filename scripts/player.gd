extends CharacterBody2D

signal damaged(damage, hp)
signal death(murderer, weapon)

var hp := 100.0

var maxSpeed = 400
const acceleration = 140.0
const friction = 34
var jumpSpeed = -230.0
const wallJumpSpeed = -210.0 # fuc kyou
const airFriction = 10

var maxWallJumps = 3
var wallJumps = maxWallJumps

var skip = false

var facingDirection: Vector2
var yAim: int # 1 up 0 none -1 down
var aimingX: bool

var wallLock = 0.0

var uiScene

const defaults = {
	"maxSpeed": 400,
	"jumpSpeed": -210.0,
	"maxWallJumps": 1,
}

@export var inputPrefix: String # p1- p2-

@onready var coyote = $coyoteTimer

func justSwapped():
	return Input.is_action_just_pressed(inputPrefix + "swap")

func teleportAndStop(pos: Vector2):
	global_position = pos
	velocity = Vector2.ZERO
	skip = true

func nudge(direction: Vector2, speed):
	velocity += -direction * speed
	
func hurt(opponentGun: GunResource):
	hp -= opponentGun.damage
	
	if hp <= 0.0:
		print("man im dead " + inputPrefix)
		
		var otherPlayer = "player1"
		if self.name == "player1":
			otherPlayer = "player2"
		
		emit_signal("death", otherPlayer, opponentGun.displayName)
		queue_free()
	
	emit_signal("damaged", opponentGun.damage, hp)

func _ready():
	uiScene = get_node("../ui")

func _physics_process(delta: float) -> void:
	if skip:
		skip = false
		return
	
	var wasOnFloor = is_on_floor()
	move_and_slide()
	
	if not is_on_floor():
		if wasOnFloor:
			coyote.start()
	if Input.is_action_pressed(inputPrefix + "up") and (is_on_floor() or not coyote.is_stopped()):
		velocity.y = jumpSpeed
	if is_on_floor():
		wallJumps = maxWallJumps
		
	velocity += get_gravity() * delta * 1.1 # I hate gravity fuck you
		
	if is_on_wall_only() and wallJumps > 0 and Input.is_action_just_pressed(inputPrefix + "up"):
		var wallNormal =  get_wall_normal().x

		wallJumps -= 1
		
		var wallSpeedX = 160
		if Input.get_axis(inputPrefix + "left", inputPrefix + "right") == -wallNormal:
			velocity.y = wallJumpSpeed * 1.3
		else:
			velocity.y = wallJumpSpeed
			wallSpeedX = 390
		
		velocity.x = wallNormal * wallSpeedX
		
		#print(Input.get_axis(inputPrefix + "left", inputPrefix + "right"))
		#print("AAAAA NORMAL", wallNormal)
		wallLock = 0.06
		if Input.get_axis(inputPrefix + "left", inputPrefix + "right"):
			wallLock = 0.12
		
	var direction := Input.get_axis(inputPrefix + "left", inputPrefix + "right")
	
	if wallLock <= 0:
		if direction:
			var speedRatio = abs(velocity.x) / maxSpeed
			var r = 1 - speedRatio
			
			velocity.x = direction * acceleration * r
			
			#velocity.x = clampf(velocity.x, -maxSpeed, maxSpeed)
		else:
			if is_on_floor():
				velocity.x = move_toward(velocity.x, 0, friction)
			else:
				velocity.x = move_toward(velocity.x, 0, airFriction)
	
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
	
	wallLock -= delta
	
func onCoyoteTimerTimeout() -> void:
	pass # Replace with function body.
