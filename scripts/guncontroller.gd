extends Node2D

var fireTime := 0.0
var gun: GunResource = load("res://guns/pistol.tres")

func shoot():
	print("fuc kit we ball idk i dont want to do anything")

func tryShoot():
	var now = Time.get_ticks_msec() / 1000.0
	
	if now < fireTime:
		return
	
	shoot()
	fireTime = now + gun.rateOfFire

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(get_parent().inputPrefix + "shoot"):
		tryShoot()
