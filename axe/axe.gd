extends Area2D
class_name Axe

@export var direction = 1
@export var linear_velocity: Vector2 = Vector2.ZERO
@export var flying: bool = true
@export var returning: bool = false

@onready var axe_sprite: Sprite2D = $AxeSprite
@onready var axe_stuck_sprite: Sprite2D = $AxeStuckSprite

@onready var recall_audio_stream_player: AudioStreamPlayer2D = $RecallAudioStreamPlayer2D
@onready var fire_particles_2d: CPUParticles2D = $FireParticles2D

var collided_viking: Viking = null
var can_pick_up: bool = false

func _ready() -> void:
	if GameManager.viking_state.skills.get("axe_fire", 0) > 0:
		fire_particles_2d.emitting = true
	if GameManager.viking_state.skills.get("axe_frost", 0) > 0:
		axe_sprite.self_modulate = Color(0.75, 0.75, 1.0)
		axe_stuck_sprite.self_modulate = Color(0.75, 0.75, 1.0)


func bounce_off_of_body(body: Node) -> void:
	if body is StaticBody2D or body is Enemy:
		var normal: Vector2 = (body.global_position - global_position).normalized()
		linear_velocity = linear_velocity.bounce(normal) * GameManager.viking_state.axe_ricochet_multiplier
		can_pick_up = true

func _on_body_entered(body:Node) -> void:
	if body is Viking:
		collided_viking = body as Viking
	elif body is Enemy and flying:
		var enemy: Enemy = body
		enemy.take_damage(GameManager.viking_state.axe_damage)
		var fire_level = GameManager.viking_state.skills.get("axe_fire", 0)
		var frost_level = GameManager.viking_state.skills.get("axe_frost", 0)

		if fire_level > 0:
			enemy.ignite()
		if frost_level > 0:
			enemy.freeze()
		bounce_off_of_body(body)
	elif body is StaticBody2D and flying:
		bounce_off_of_body(body)

func _input(event: InputEvent) -> void:
	var recall_level = GameManager.viking_state.skills.get("axe_recall", 0)
	if recall_level > 0 and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		returning = true
		recall_audio_stream_player.play()

func _physics_process(_delta: float) -> void:
	position += linear_velocity * _delta
	rotation = cos(linear_velocity.length() * 0.01) * PI * 0.75 * direction

	linear_velocity *= 0.9 + GameManager.viking_state.skills.get("axe_range", 0) * 0.03  

	if linear_velocity.length() < 30:
		linear_velocity = Vector2.ZERO
		flying = false

	if returning:
		var viking_position = GameManager.viking.global_position
		var direction_to_viking = (viking_position - global_position).normalized()
		linear_velocity = direction_to_viking * GameManager.viking_state.axe_throw_speed

	if flying:
		axe_sprite.visible = true
		axe_stuck_sprite.visible = false
	else:
		axe_sprite.visible = false
		axe_stuck_sprite.visible = true
		axe_stuck_sprite.flip_h = direction > 0

	if collided_viking != null and (returning or can_pick_up or !flying):
		collided_viking.pick_up_axe()
		queue_free()

func _on_body_exited(body:Node2D) -> void:
	if body is Viking:
		collided_viking = null
		can_pick_up = true
