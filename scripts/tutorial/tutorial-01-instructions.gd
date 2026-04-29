extends Node2D

var inLabel1 = []
var inLabel2 = []

@onready var label1: Label = get_node("1")
@onready var label2: Label = get_node("2")

func bodyEnteredLabel1(body: Node2D) -> void:
	#daefend for a bit srry
	if body.name != "player1":
		return
	
	inLabel1.append(body)


func bodyExitedLabel1(body: Node2D) -> void:
	if body.name != "player1":
		return
	
	inLabel1.erase(body)

func _process(_delta: float) -> void:
	var occupationLabel1 = false
	for body in inLabel1:
		if body.is_in_group("player") and label1.modulate.a < 1:
			occupationLabel1 = true
			var tween = create_tween()
			tween.tween_property(label1, "modulate:a", 1, 0.5)
	
	if !occupationLabel1 and label1.modulate.a > 0:
		var tween = create_tween()
		tween.tween_property(label1, "modulate:a", 0, 0.5)
	
	var occupationLabel2 = false
	for body in inLabel2:
		if body.is_in_group("player") and label2.modulate.a < 1:
			print("bah")
			occupationLabel2 = true
			var tween = create_tween()
			tween.tween_property(label2, "modulate:a", 1, 0.5)
	
	if !occupationLabel2 and label2.modulate.a > 0:
		var tween = create_tween()
		tween.tween_property(label2, "modulate:a", 0, 0.5)
	
	print(inLabel1, "   ONE")
	print(inLabel1, "   TWO")


func bodyEnteredLabel2(body: Node2D) -> void:
	if body.name != "player1":
		return
	
	inLabel2.append(body)


func bodyExitedLabel2(body: Node2D) -> void:
	if body.name != "player1":
		return
	
	inLabel2.erase(body)
