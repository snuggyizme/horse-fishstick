extends Resource
class_name GunResource

@export var damage: float # only float because of .5s no more complex than that
@export var rateOfFire: float # seconds between shots
@export var rangeLimit: int # pixels
@export var recoil: float # percent
@export var spread: float # degrees
@export var tracerColour: String # hex no hashtag
@export var tracerColourFade: String # hex no hastag
@export var knockback: float # percent
@export var auto: bool # click spam or hold

@export var isHitscan: bool
@export var projectileSpeed: int # only if isHitscan=false. pix/sec

@export var displayName: String
@export var visual: PackedScene

@export var isBurst: bool # clump bullets in bursts
@export var burstSize: int # only if isBursts = true
@export var burstRate: float # seconds betweeen bursts

@export var ammo: int 

@export var bulletsPerShot: int # shotgun
@export var doBullertsPerShotWithBurstAmmo: bool # if so, the shotgun will consume the ammo of the burst to fire it. if false, the shotgun will fire bulletsPerShot and take 1 ammo.
