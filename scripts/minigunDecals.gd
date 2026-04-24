extends Node2D

@onready var heat = $decals/heat

var coolDownTime := 0.0
var shotsRecently := 0

var glowing = false

func onShoot():
	coolDownTime = Time.get_ticks_msec() + 930
	shotsRecently += 1
	
	bulletCasing()
	
func _process(_delta):
	if shotsRecently == 0 and not glowing:
		heat.modulate = Color(1, 1, 1, 0)
	
	if shotsRecently >= 5 and not glowing:
		glowing = true
		var glowTween = create_tween()
		glowTween.tween_property(heat, "modulate", Color(3, 3, 3, 0.8), 0.1)
		glowTween.set_ease(Tween.EASE_OUT)
	
	if Time.get_ticks_msec() > coolDownTime and shotsRecently > 0:
		glowing = false
		shotsRecently -= 1
		
		if shotsRecently <= 0:
			shotsRecently = 0
			glowing = false
		
		var glowTween = create_tween()
		glowTween.tween_property(heat, "modulate", Color(2, 1, 1, 0), 0.3)

func bulletCasing():
	var casing = load("res://scenes/casing.tscn").instantiate()
	get_tree().current_scene.add_child(casing)
	casing.global_position = $casingSpawner.global_position
	casing.get_node("rigidbody").sleeping = false
	
	var randX
	if get_parent().get_parent().facingDirection == Vector2.RIGHT:
		randX = randi_range(-40, -50)
	else:
		randX = randi_range(40, 50)
	casing.get_node("rigidbody").apply_impulse(Vector2(randX, -randi_range(120, 210)))
	
	var tween = create_tween()
	tween.tween_property(casing, "modulate:a", 0, 3)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_callback(casing.queue_free)
