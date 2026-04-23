extends Node2D

@onready var muzzle = $muzzle
var topBarrelPos = Vector2(15, -2)
var bottomBarrelPos = Vector2(15, 0)
var currentBarrel = 0

func onShoot():
	if currentBarrel == 0:
		currentBarrel = 1
	else:
		currentBarrel = 0
	
	match currentBarrel:
		0:
			muzzle.position = topBarrelPos
		1:
			muzzle.position = bottomBarrelPos
