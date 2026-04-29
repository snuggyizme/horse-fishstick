extends Node2D

func temporary() -> void:
	Maploader.expectTutorial = true
	var delay = Timer.new()
	add_child(delay)
	delay.start()
	await delay.timeout
	get_tree().change_scene_to_file("res://scenes/main.tscn")
