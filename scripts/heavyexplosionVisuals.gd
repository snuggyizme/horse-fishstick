extends Node2D

const damage = 33.5

const speedShrapnel = 15
const speedFire = 3
const speedSmoke = 2

var particles = []

var assets = {
	"shrapnel": [
		preload("res://assets/sprites/explosions/heavy/shrapnel1.png"),
		preload("res://assets/sprites/explosions/heavy/shrapnel2.png"),
	],
	"smoke": [
		preload("res://assets/sprites/explosions/heavy/smoke1.png"),
		preload("res://assets/sprites/explosions/heavy/smoke2.png"),
	],
	"fire": [
		preload("res://assets/sprites/explosions/heavy/fire1.png"),
		preload("res://assets/sprites/explosions/heavy/fire2.png"),
	]
}

func explode(normal):
	var countShrapnel = randi_range(45, 120)
	var countFire = randi_range(3, 6)
	var countSmoke = 3
	
	print(normal)
	
	for i in range(countShrapnel):
		var sprite = assets["shrapnel"][randi_range(0, len(assets["shrapnel"]) - 1)]
		var vel = (normal * speedShrapnel * randf_range(0.95, 9.95)).rotated(deg_to_rad(randi_range(-60, 60)))
		var age = randf_range(0.3, 0.4)
		particles.append({
			"pos": Vector2.ZERO,
			"vel": vel,
			"rot": Vector2.RIGHT.angle_to(normal),
			"tex": sprite,
			"age": age,
			"typ": "shrapnel",
			"max": age
		})
		
	#if true: return # GAH!
	
	for i in range(countFire):
		var sprite = assets["fire"][randi_range(0, len(assets["fire"]) - 1)]
		var vel = (normal * speedFire * randf_range(0.75, 9.75)).rotated(deg_to_rad(randi_range(-50, 50)))
		var age = randf_range(0.3, 0.4)
		particles.append({
			"pos": Vector2.ZERO,
			"vel": vel,
			"rot": Vector2.RIGHT.angle_to(normal),
			"tex": sprite,
			"age": age,
			"typ": "fire",
			"max": age
		})
	
	#if true: return # GAH!
	
	for i in range(countSmoke):
		var sprite = assets["smoke"][randi_range(0, len(assets["smoke"]) - 1)]
		var vel = (normal * speedSmoke * randf_range(0.75, 1.75)).rotated(deg_to_rad(randi_range(-60, 60)))
		var age = randf_range(0.3, 0.4)
		particles.append({
			"pos": Vector2.ZERO,
			"vel": vel,
			"rot": Vector2.RIGHT.angle_to(normal),
			"tex": sprite,
			"age": age,
			"typ": "smoke",
			"max": age
		})

func _process(delta):
	for p in particles:
		if p["typ"] != "shrapnel":
			p["pos"] += p["vel"] * delta
		p["age"] -= delta
		
	particles = particles.filter(func(p): return p["age"] > 0)
	queue_redraw()

func _draw():
	for type in ["smoke", "fire", "shrapnel"]:
		for p in particles:
			if p["typ"] != type:
				continue
			
			match p["typ"]:
				"shrapnel":
					draw_set_transform(p["pos"], p["rot"], Vector2.ONE)
					
				"fire":
					draw_set_transform(p["pos"], p["rot"], Vector2(2, 2))
				"smoke":
					draw_set_transform(p["pos"], p["rot"], Vector2(2, 2))
			
			draw_texture(p["tex"], -p["tex"].get_size() / 2, Color(3, 3, 3, p["age"] / p["max"]))
	
