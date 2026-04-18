extends Resource
class_name GunResource

@export var damage: float # only float because of .5s no more complex than that
@export var rateOfFire: float # seconds between shots
@export var rangeLimit: int # pixels
@export var recoil: float # percent
@export var spread: float # degrees
@export var tracerColour: String # idk how this is gonna work
@export var knockback: float # percent

@export var isHitscan: bool
@export var projectileSpeed: int # only if isHitscan=false. pix/sec

@export var displayName: String
@export var sprite: String
