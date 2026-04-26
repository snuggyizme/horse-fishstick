extends Node2D

var player1
var player2
var p1_hp := 100
var p2_hp := 100
@onready var p1_bar: ProgressBar = $p1_hp
@onready var p2_bar: ProgressBar = $p2_hp
@onready var killFeed: RichTextLabel = $feed

var killFeedText = []

func _ready():
	Maploader.ui = self
	Maploader.playerReady.connect(bindPlayers)

func bindPlayers(p1, p2):
	self.player1 = p1
	self.player2 = p2
	
	if self.player1:
		if self.player1.damaged.is_connected(_onPlayerOneHit):
			self.player1.damaged.disconnect(_onPlayerOneHit)
	
	if self.player1:
		if self.player1.damaged.is_connected(_onPlayerTwoHit):
			self.player1.damaged.disconnect(_onPlayerTwoHit)
	
	self.p1_hp = p1.hp
	self.p2_hp = p2.hp
	updateBars()
	
	if not p1.damaged.is_connected(_onPlayerOneHit):
		p1.damaged.connect(_onPlayerOneHit)
	if not p2.damaged.is_connected(_onPlayerTwoHit):
		p2.damaged.connect(_onPlayerTwoHit)
		
	if not p1.death.connect(feedAddKill):
		p1.death.connect(feedAddKill)
	if not p2.death.connect(feedAddKill):
		p2.death.connect(feedAddKill)

func _onPlayerOneHit(dmg, newHp):
	p1_hp = newHp
	updateBars()
	
func _onPlayerTwoHit(dmg, newHp):
	p2_hp = newHp
	updateBars()

func updateBars():
	p1_bar.value = player1.hp
	p2_bar.value = player2.hp
	
# KILL FEED BELOW ######################################################################################
# ######################################################################################################
# ######################################################################################################

func feedAddKill(offender, victim, shiv):
	killFeed.modulate = Color(1, 1, 1, 1)
	killFeedText.append(offender.to_upper() + " » " + victim.to_upper() + " (" + shiv + ")")
	
	if len(killFeedText) > 3:
		killFeedText.pop(0)
		
	var builtText = ""
	for i in killFeedText:
		builtText += i + "\n"
	killFeed.set_text(builtText)
	
	var tween = create_tween()
	tween.tween_property(killFeed, "modulate", Color(0, 0, 3, 0), 5.9)
