extends Resource
class_name GunResource

@export_category("General")
@export var damage: float ## Damage applied. Must be in increments of 0.5
@export var rateOfFire: float ## Seconds between shots
@export var rangeLimit: int ## Measured in pixels
@export var recoil: float # percent of random number lol
@export var spread: float ## Measured in degrees
@export var knockback: float # same as recoil but different magic number
@export var auto: bool ## True = full auto. False = spam

@export_category("Tracers")
@export var tracerColour: String ## Format: RRGGBB
@export var tracerColourFade: String ## Format: RRGGBB
@export var overrideTracers: bool ## True = Use the above values instead of the defaults.
@export var doTracersGlow: bool ## Make the tracers emmisive
@export var fadeTime: float ## Seconds until the tracers fade and disappear
@export var overrideFade: bool ## True = Use the above value instead of the default

@export_category("Hitscan / Projectile")
@export var isProjectile: bool ## True = projectile weapon that takes time to move. False = hitscan
@export var projectileSpeed: int ## Projectile speed in pixels / second. Only if Is Projectile = true.
@export var projectileDrop: float ## Gravity effect applied to the projectile. Only if Is Projectile = true.
@export var useShapeCast: bool ## True = fired projectile is a hitscan laser that travels through walls. Using this with Is Projectile will prioritise the projectile and not fire the laser.
@export var LaserSize: int ## Width of the shapecast in pixels. Only if Use Shapecast = true.

@export_category("Visuals")
@export var displayName: String ## Name showed in gun spawners
@export var visual: PackedScene ## A scene containing a Sprite2D called 'gun' and a Marker2D called 'muzzle'. The root Node2D can contain certain scripts to draw VFX / decals.

@export_category("Burst Fire")
@export var isBurst: bool ## True = Clump bullets into bursts. Rate Of Fire becomes the reload speed.
@export var burstSize: int ## Bullets per burst. Only if Is Burst = true.
@export var burstRate: float ## Seconds between shots WITHIN a burst. Bullets per burst. Only if Is Burst = true.

@export_category("Ammo")
@export var ammo: int ## Ammo count

@export_category("Shotgun")
@export var bulletsPerShot: int ## Pellets per shot
@export var doBullertsPerShotWithBurstAmmo: bool ## True = Shotgun that requires Is Burst and uses 1 ammo within the burst per pellet. Also somehow works for the other case of being a non-burst shottgun (consumes 1 ammo per shot) and I should probably fix it

@export_category("SFX")
@export_enum(
	"LIGHT", "MEDIUM", "HEAVY", "SHOTGUN_LIGHT", "SHOTGUN_HEAVY", "POWER_LIGHT", "POWER_MEDIUM", "POWER_HEAVY", "LASER_HEAVY"
) var shootSound ## <3 CY4
@export var doKaping: bool ## Play a delayed kaping sound after shooting. See: M1903
