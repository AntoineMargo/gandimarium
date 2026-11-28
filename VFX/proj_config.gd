extends Resource
class_name ProjConfig

## Texture used for the projectile's main visual.
@export var sprite: Texture2D

## 0.01–5.0: multiplier applied to the sprite's original size.
@export_range(0.01, 5.0, 0.01) var sprite_scale: float = 1.0

## Any Color: tint applied to the projectile sprite.
@export var colour: Color = Color(1.0, 1.0, 1.0, 1.0)

## 1–5000: projectile movement speed, in pixels per second.
@export_range(1.0, 5000.0, 1.0) var speed: float = 800.0

## -500–500 pixels recommended: signed lateral offset of the trajectory.
## 0 = straight line. Sign determines which side of the trajectory it curves toward.
@export var trajectory_arc: float = 0.0

## 0–1: random variation in arc magnitude. 0 = fixed arc; 1 = maximum variation.
@export_range(0.0, 1.0, 0.01) var trajectory_randomness: float = 1.0

## 0–1: probability of reversing the arc direction. 0 = never; 1 = always.
@export_range(0.0, 1.0, 0.01) var trajectory_direction_randomness: float = 0.5

## 0–200 pixels: maximum lateral displacement caused by wobble. 0 = disabled.
@export_range(0.0, 200.0, 0.1) var wobble_amplitude: float = 0.0

## 0–30: frequency of the wobble. Exact perceived speed depends on the trajectory formula.
@export_range(0.0, 30.0, 0.1) var wobble_frequency: float = 3.0

## Any number of particle emitter configurations attached to this projectile.
@export var particles: Array[ParticleConfig] = []
