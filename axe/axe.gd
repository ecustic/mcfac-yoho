extends Area2D
class_name Axe

@export var direction = 1
@export var linear_velocity: Vector2 = Vector2.ZERO
@export var flying: bool = true

@onready var axe_sprite: Sprite2D = $AxeSprite
@onready var axe_stuck_sprite: Sprite2D = $AxeStuckSprite

func _on_body_entered(body:Node) -> void:
	print("Axe collided with: ", body.name)
	if body is Viking and not flying:
		var viking: Viking = body
		viking.pick_up_axe()
		queue_free()

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
		axe_stuck_sprite.flip_h = direction > 0
		axe_stuck_sprite.visible = true