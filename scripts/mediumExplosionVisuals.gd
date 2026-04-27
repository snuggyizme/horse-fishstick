extends Node2D

const speedParticles = 15
const speedFire = 3
const speedSmoke = 2

var particles = []

var assets = {
	"particle": [
		preload("res://assets/sprites/explosions/medium/particle1.png"),
		preload("res://assets/sprites/explosions/medium/particle2.png"),
	],
	"smoke": [
		preload("res://assets/sprites/explosions/medium/smoke1.png"),
		preload("res://assets/sprites/explosions/medium/smoke2.png"),
	],
	"fire": [
		preload("res://assets/sprites/explosions/medium/fire1.png"),
		preload("res://assets/sprites/explosions/medium/fire2.png"),
		preload("res://assets/sprites/explosions/medium/fire3.png"),
	]
}

func explode(normal):
	var countParticles = randi_range(45, 120)
	var countFire = randi_range(3, 6)
	var countSmoke = 3
	
	for i in range(countParticles):
		var sprite = assets["particle"][randi_range(0, len(assets["particle"]) - 1)]
		particles.append({
			"pos": Vector2.ZERO,
			"vel": (normal * speedParticles * randf_range(0.95, 9.95)).rotated(deg_to_rad(randi_range(-60, 60))),
			"rot": deg_to_rad(randi_range(0, 359)),
			"tex": sprite,
			"age": randf_range(0.4, 0.6), # particles are old boys
			"typ": "particle"
		})
		
	#if true: return # GAH!
	
	for i in range(countFire):
		var sprite = assets["fire"][randi_range(0, len(assets["fire"]) - 1)]
		particles.append({
			"pos": Vector2.ZERO,
			"vel": (normal * speedFire * randf_range(0.75, 9.75)).rotated(deg_to_rad(randi_range(-50, 50))),
			"rot": deg_to_rad(randi_range(0, 359)),
			"tex": sprite,
			"age": randf_range(0.3, 0.4),
			"typ": "fire"
		})
	
	#if true: return # GAH!
	
	for i in range(countSmoke):
		var sprite = assets["smoke"][randi_range(0, len(assets["smoke"]) - 1)]
		particles.append({
			"pos": Vector2.ZERO,
			"vel": (normal * speedSmoke * randf_range(0.75, 1.75)).rotated(deg_to_rad(randi_range(-60, 60))),
			"rot": deg_to_rad(randi_range(0, 359)),
			"tex": sprite,
			"age": randf_range(0.3, 0.4),
			"typ": "smoke"
		})

func _process(delta):
	for p in particles:
		p["pos"] += p["vel"] * delta
		p["age"] -= delta
		
	particles = particles.filter(func(p): return p["age"] > 0)
	queue_redraw()

func _draw():
	for type in ["smoke", "fire", "particle"]:
		for p in particles:
			if p["typ"] != type:
				continue
			
			match p["typ"]:
				"particle":
					draw_set_transform(p["pos"], p["rot"], Vector2.ONE)
					
				"fire":
					draw_set_transform(p["pos"], p["rot"], Vector2(2, 2))
				"smoke":
					draw_set_transform(p["pos"], p["rot"], Vector2(2, 2))
			
			draw_texture(p["tex"], -p["tex"].get_size() / 2, Color(3, 3, 3))
