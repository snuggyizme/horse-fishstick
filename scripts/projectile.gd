extends CharacterBody2D

var gravity := 0.0
var speed := 0.0
var bounces := 0

func setType(gun: GunResource):
	gravity = gun.projectileDrop
	speed = gun.projectileSpeed
	bounces = gun.projectileBounces
