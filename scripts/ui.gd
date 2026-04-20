extends Node2D

var p1_hp := 100.0
var p2_hp := 100.0
@onready var p1_bar: ProgressBar = $p1_hp
@onready var p2_bar: ProgressBar = $p2_hp

func _ready():
	Maploader.ui = self

func bindPlayers(p1, p2):
	if not p1.damaged.is_connected(_onPlayerOneHit):
		p1.damaged.connect(_onPlayerOneHit)
	if not p2.damaged.is_connected(_onPlayerTwoHit):
		p2.damaged.connect(_onPlayerTwoHit)

func _onPlayerOneHit(dmg, newHp):
	p1_hp = newHp
	updateBars()
	
func _onPlayerTwoHit(dmg, newHp):
	p2_hp = newHp
	updateBars()

func updateBars():
	p1_bar.value = p1_hp
	p2_bar.value = p2_hp
