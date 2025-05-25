extends Area2D
class_name Axe

@export var direction = 1
@export var linear_velocity: Vector2 = Vector2.ZERO
@export var flying: bool = true
@export var bounce_multiplier: float = 1

@export var damage: int = 1

@onready var axe_sprite: Sprite2D = $AxeSprite
@onready var axe_stuck_sprite: Sprite2D = $AxeStuckSprite

var viking: Viking = null
var can_pick_up: bool = false

func bounce_off_of_body(body: Node) -> void:
	if body is StaticBody2D or body is Enemy:
		var normal: Vector2 = (body.global_position - global_position).normalized()
		linear_velocity = linear_velocity.bounce(normal) * bounce_multiplier
		can_pick_up = true

func _on_body_entered(body:Node) -> void:
	if body is Viking:
		viking = body as Viking
	elif body is Enemy and flying:
		var enemy: Enemy = body
		enemy.take_damage(damage)
		bounce_off_of_body(body)
	elif body is StaticBody2D and flying:
		bounce_off_of_body(body)

func _physics_process(_delta: float) -> void:
	position += linear_velocity * _delta
	rotation = cos(linear_velocity.length() * 0.01) * PI * 0.75 * direction

	linear_velocity *= 0.9  

	if linear_velocity.length() < 30:
		linear_velocity = Vector2.ZERO
		flying = false

	if flying:
		axe_sprite.visible = true
		axe_stuck_sprite.visible = false
	else:
		axe_sprite.visible = false
		axe_stuck_sprite.visible = true
		axe_stuck_sprite.flip_h = direction > 0

	if viking != null and (can_pick_up or !flying):
		viking.pick_up_axe()
		queue_free()

func _on_body_exited(body:Node2D) -> void:
	if body is Viking:
		viking = null
		can_pick_up = true
