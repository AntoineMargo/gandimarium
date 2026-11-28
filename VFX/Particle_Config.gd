extends Resource
class_name ParticleConfig

## Texture used for each individual particle.
@export var texture: Texture2D

## 1–1000: maximum number of particles alive at once.
@export_range(1, 1000, 1) var amount: int = 20

## 0.01–30 seconds: how long each particle remains alive.
@export_range(0.01, 30.0, 0.01) var lifetime: float = 0.5

## false = continuously emit particles. true = emit a single burst.
@export var one_shot: bool = false

@export_group("Movement")

## Direction of emission in local space. Normally a normalized vector.
## LEFT emits behind a projectile facing its target.
@export var direction: Vector2 = Vector2.LEFT

## 0–180 degrees: angular spread around the emission direction.
@export_range(0.0, 180.0, 1.0) var spread: float = 180.0

## 0–2000 pixels per second: minimum initial particle velocity.
@export_range(0.0, 2000.0, 1.0) var velocity_min: float = 50.0

## 0–2000 pixels per second: maximum initial particle velocity.
## Should be equal to or greater than velocity_min.
@export_range(0.0, 2000.0, 1.0) var velocity_max: float = 100.0

## Recommended: -1000 to 1000 pixels per second squared on each axis.
## Vector2.ZERO = no gravity.
@export var gravity: Vector2 = Vector2.ZERO

@export_group("Appearance")

## 0.001–5.0: minimum particle scale multiplier.
@export_range(0.001, 5.0, 0.001) var scale_min: float = 0.05

## 0.001–5.0: maximum particle scale multiplier.
## Should be equal to or greater than scale_min.
@export_range(0.001, 5.0, 0.001) var scale_max: float = 0.15

## Any Color: tint applied to the particles.
@export var colour: Color = Color.WHITE

## true = fade particles toward transparency over their lifetime.
@export var fade: bool = true

@export_group("Emission")

## 0–1: controls how concentrated particle emission is in time.
## 0 = particles are emitted evenly throughout the emission cycle.
## 1 = particles are emitted together in a burst.
@export_range(0.0, 1.0, 0.01) var explosiveness: float = 0.0
