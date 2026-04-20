extends Node2D

var p1
var p2
var p1_hp := 100
var p2_hp := 100
@onready var p1_bar: ProgressBar = $p1_hp
@onready var p2_bar: ProgressBar = $p2_hp

func _ready():
	Maploader.ui = self
	Maploader.playerReady.connect(bindPlayers)

func bindPlayers(p1, p2):
	if self.p1:
		if self.p1.damaged.is_connected(_onPlayerOneHit):
			self.p1.damaged.disconnect(_onPlayerOneHit)
	
	if self.p2:
		if self.p2.damaged.is_connected(_onPlayerTwoHit):
			self.p2.damaged.disconnect(_onPlayerTwoHit)
	
	self.p1 = p1
	self.p2 = p2
	
	self.p1_hp = p1.hp
	self.p2_hp = p2.hp
	updateBars()
	
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
	p1_bar.value = p1.hp
	p2_bar.value = p2.hp
