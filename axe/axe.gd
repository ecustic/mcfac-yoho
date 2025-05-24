extends Area2D
class_name Axe

@export var direction = 1
@export var linear_velocity: Vector2 = Vector2.ZERO
@export var flying: bool = true

@export var damage: int = 1

@onready var axe_sprite: Sprite2D = $AxeSprite
@onready var axe_stuck_sprite: Sprite2D = $AxeStuckSprite

var colliding_with_viking: Viking = null

func _on_body_entered(body:Node) -> void:
	print("Axe collided with: ", body.name)
	if body is Viking:
		colliding_with_viking = body as Viking
	elif body is Enemy and flying:
		var enemy: Enemy = body
		enemy.take_damage(damage)
		linear_velocity = -linear_velocity
		direction = -direction
	elif body is StaticBody2D and flying:
		linear_velocity = -linear_velocity
		direction = -direction

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

	if colliding_with_viking != null and !flying:
		colliding_with_viking.pick_up_axe()
		queue_free()

func _on_body_exited(body:Node2D) -> void:
	print("Axe exited collision with: ", body.name)
	if body is Viking:
		colliding_with_viking = null
