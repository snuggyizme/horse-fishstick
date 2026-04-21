extends Node2D

@onready var decal = $decals/decal1

func onShoot():
	decal.z_index = 7
	decal.modulate = Color(6, 6, 6, 1)
	
	var tween = create_tween()
	tween.tween_property(decal, "modulate", Color(1, 1, 1, 1), 2)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

func onDryAmmo():
	var tween = create_tween()
	tween.tween_property(decal, "modulate", Color(3, 1, 1, 0), 3)
