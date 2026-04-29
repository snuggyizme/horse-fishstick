extends Node2D

var player1
var player2
var p1_hp := 100
var p2_hp := 100
@onready var p1_bar: ProgressBar = $p1_hp
@onready var p2_bar: ProgressBar = $p2_hp
@onready var killFeed: RichTextLabel = $feed

var killFeedText = []
var alreadyKill
var lastTime = 0.0
var livingPlayers = [true, true]

func _ready():
	Maploader.ui = self
	Maploader.playerReady.connect(bindPlayers)

func bindPlayers(p1, p2):
	self.player1 = p1
	self.player2 = p2
	
	if self.player1:
		if self.player1.damaged.is_connected(_onPlayerOneHit):
			self.player1.damaged.disconnect(_onPlayerOneHit)
		
		self.p1_hp = p1.hp
	
	if self.player2:
		if self.player2.damaged.is_connected(_onPlayerTwoHit):
			self.player2.damaged.disconnect(_onPlayerTwoHit)
		
		self.p2_hp = p2.hp
	
	updateBars()
	
	if self.player1:
		if not p1.damaged.is_connected(_onPlayerOneHit):
			p1.damaged.connect(_onPlayerOneHit)
		if not p1.death.is_connected(feedAddKill):
			p1.death.connect(feedAddKill)
		
	if self.player2:
		if not p2.death.is_connected(feedAddKill):
			p2.death.connect(feedAddKill)
		if not p2.damaged.is_connected(_onPlayerTwoHit):
			p2.damaged.connect(_onPlayerTwoHit)

func _onPlayerOneHit(dmg, newHp):
	p1_hp = newHp
	updateBars()
	
func _onPlayerTwoHit(dmg, newHp):
	p2_hp = newHp
	updateBars()

func updateBars():
	if player1:
		p1_bar.value = player1.hp
		if player1.hp > 0:
			livingPlayers[0] = true
	if player2:
		p2_bar.value = player2.hp
		if player2.hp > 0:
			livingPlayers[1] = true
	
	
# KILL FEED BELOW ######################################################################################
# ######################################################################################################
# ######################################################################################################

func feedAddKill(offender, victim, shiv):
	if alreadyKill: # idk which one is doing the most lets have all 3
		pass
	alreadyKill = true
	
	var timeClearance = 10
	var time = Time.get_ticks_msec()
	
	if abs(time - lastTime) <= timeClearance: # idk which one is doing the most lets have all 3
		return
		
	if victim == "player1": # idk which one is doing the most lets have all 3
		if livingPlayers[0]:
			livingPlayers[0] = false
		else:
			return
	elif victim == "player2":
		if livingPlayers[1]:
			livingPlayers[1] = false
		else:
			return
	
	killFeed.modulate = Color(1, 1, 1, 1)
	killFeedText.append(offender.to_upper() + " » " + victim.to_upper() + " (" + shiv + ")")
	
	#print(killFeedText[-1])
	
	if len(killFeedText) > 3:
		killFeedText.pop_front()
		
	var builtText = ""
	for i in killFeedText:
		builtText += i + "\n"
	killFeed.set_text(builtText)
	
	var tween = create_tween()
	tween.tween_property(killFeed, "modulate", Color(0, 0, 3, 0), 5.9)
	
	lastTime = Time.get_ticks_msec()
func _process(_delta: float) -> void:
	alreadyKill = false
