extends Node2D

func onShoot():
	bulletCasing()

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
