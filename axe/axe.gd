extends Area2D
class_name Axe

@export var linear_velocity: Vector2 = Vector2.ZERO
@export var angular_velocity: float = 0.0

func _on_body_entered(body:Node) -> void:
	print("Axe collided with: ", body.name)
	if body is Viking and linear_velocity.length() < 0.1:
		var viking: Viking = body
		viking.pick_up_axe()
		queue_free()

func _physics_process(_delta: float) -> void:
		position += linear_velocity * _delta
		rotation += angular_velocity * _delta

		linear_velocity *= 0.9  
		angular_velocity *= 0.9 