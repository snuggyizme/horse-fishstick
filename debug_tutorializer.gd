extends Node2D

func temporary() -> void:
	Maploader.expectTutorial = true
	get_tree().change_scene_to_file("res://scenes/main.tscn")
