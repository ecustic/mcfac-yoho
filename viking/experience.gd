extends Area2D
class_name Experience

@export var value: int = 1

var speed: float = 100.0
var viking: Viking = null

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

var colors = [
	Color(0.8, 0.8, 0.2),
	Color(0.2, 0.8, 0.2), 
	Color(0.2, 0.2, 0.8), 
	Color(0.8, 0.2, 0.2), 
	Color(0.8, 0.5, 0.2)  
]

func _ready() -> void:
	scale = Vector2.ONE * (1 + (float(value) / 10))
	var color_index = value % colors.size()
	modulate = colors[color_index]

func _physics_process(delta: float) -> void:
	if viking:
		var direction = (viking.global_position - global_position).normalized()
		var velocity = direction * speed
		position += velocity * delta

func _on_body_entered(body:Node2D) -> void:
	if body is Viking:
		visible = false
		GameManager.viking_state.add_xp(value)
		audio_stream_player_2d.pitch_scale = 0.75 + randf() * 0.5
		audio_stream_player_2d.play()

func follow_viking(viking: Viking) -> void:
	self.viking = viking

func _on_audio_stream_player_2d_finished() -> void:
	queue_free() 
