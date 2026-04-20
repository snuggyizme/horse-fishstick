extends CharacterBody2D

signal damaged(damage, hp)

var hp := 100.0

var maxSpeed = 400
const acceleration = 140.0
const friction = 34
var jumpSpeed = -210.0
const wallJumpSpeed = -310.0 # fuc kyou
const airFriction = 10

var maxWallJumps = 1
var wallJumps = maxWallJumps

var skip = false

var facingDirection: Vector2
var yAim: int # 1 up 0 none -1 down
var aimingX: bool

const defaults = {
	"maxSpeed": 400,
	"jumpSpeed": -210.0,
	"maxWallJumps": 1,
}

@export var inputPrefix: String # p1- p2-

func justSwapped():
	return Input.is_action_just_pressed(inputPrefix + "swap")

func teleportAndStop(pos: Vector2):
	global_position = pos
	velocity = Vector2.ZERO
	skip = true

func nudge(direction, speed):
	velocity += direction * speed
	
func hurt(damage: float):
	hp -= damage
	
	if hp <= 0.0:
		print("man im dead " + inputPrefix)
		queue_free()
	
	emit_signal("damaged", damage, hp)

func _physics_process(delta: float) -> void:
	if skip:
		skip = false
		return
	
	if not is_on_floor():
		velocity += get_gravity() * delta * 1.1 # I hate gravity fuck you
	elif Input.is_action_pressed(inputPrefix + "up"):
		velocity.y = jumpSpeed
	else:
		wallJumps = maxWallJumps
		
	if is_on_wall_only() and wallJumps > 0 and Input.is_action_just_pressed(inputPrefix + "up"):
		velocity.y = wallJumpSpeed
		wallJumps -= 1
		
	var direction := Input.get_axis(inputPrefix + "left", inputPrefix + "right")
	
	if direction:
		var speedRatio = abs(velocity.x) / maxSpeed
		var r = 1 - speedRatio
		
		velocity.x = direction * acceleration * r
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
	
	move_and_slide()
	
	
