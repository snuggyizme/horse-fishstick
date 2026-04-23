extends Resource
class_name GunResource

@export_category("General")
@export var damage: float # only float because of .5s no more complex than that
@export var rateOfFire: float # seconds between shots
@export var rangeLimit: int # pixels
@export var recoil: float # percent
@export var spread: float # degrees
@export var knockback: float # percent
@export var auto: bool # click spam or hold

@export_category("Tracers")
@export var tracerColour: String # hex no hashtag
@export var tracerColourFade: String # hex no hastag
@export var overrideTracers: bool
@export var doTracersGlow: bool
@export var fadeTime: float
@export var overrideFade: bool

@export_category("Hitscan / Projectile")
@export var isProjectile: bool
@export var projectileSpeed: int # only if isProjectile=true. pix/sec
@export var useShapeCast: bool # true= a wide projectile. false= 1pix/exact
@export var LaserSize: int # only true if useShapeCast=true. pix

@export_category("Visuals")
@export var displayName: String
@export var visual: PackedScene

@export_category("Burst Fire")
@export var isBurst: bool # clump bullets in bursts
@export var burstSize: int # only if isBursts = true
@export var burstRate: float # seconds betweeen bursts

@export_category("Ammo")
@export var ammo: int 

@export_category("Shotgun")
@export var bulletsPerShot: int # shotgun
@export var doBullertsPerShotWithBurstAmmo: bool # if so, the shotgun will consume the ammo of the burst to fire it. if false, the shotgun will fire bulletsPerShot and take 1 ammo.

@export_category("SFX")
@export_enum(
	"LIGHT", "MEDIUM", "HEAVY", "SHOTGUN_LIGHT", "SHOTGUN_HEAVY", "POWER_LIGHT", "POWER_MEDIUM", "POWER_HEAVY", "LASER_HEAVY"
) var shootSound # yep thats right I LOVE YOU CY4
@export var doKaping: bool # kaping
