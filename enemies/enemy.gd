extends CharacterBody2D
class_name Enemy

@export var health: float = 1
@export var damage: float = 1
@export var speed: float = 10
@export var reward_experience: int = 1

@export var invincibility_time: float = 0
@export var on_hit_sound: AudioStream = null
@export var idle_sound: AudioStream = null

@onready var viking = GameManager.viking

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var on_hit_audio_player: AudioStreamPlayer2D = $OnHitAudioStreamPlayer2D
@onready var idle_audio_player: AudioStreamPlayer2D = $IdleAudioStreamPlayer2D
@onready var fire_particles_2d: CPUParticles2D = $FireParticles2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hurt_box: Area2D = $HurtBox

@onready var sprite = $Sprite2D

var burning_ticks: int = 0
var burning_timer: float = 0

var frozen_timer: float = 0.0

var attacking = false

var idle_sound_timer: float = 0.0

var original_modulate: Color = Color(1.0, 1.0, 1.0)

func ignite() -> void:
	var fire_level = GameManager.viking_state.skills.get("axe_fire", 0)
	burning_timer = 1.5 / fire_level
	burning_ticks = 2 * fire_level

func freeze() -> void:
	original_modulate = modulate
	var frost_level = GameManager.viking_state.skills.get("axe_frost", 0)
	frozen_timer = 2.0 + (frost_level * 1)

func _ready() -> void:
	if on_hit_sound:
		on_hit_audio_player.stream = on_hit_sound
	if idle_sound:
		idle_audio_player.stream = idle_sound
	
	on_hit_audio_player.pitch_scale = clamp(1.0 + ((1 - scale.y) * 0.25), 0, 2)
	idle_audio_player.pitch_scale = clamp(1.0 + ((1 - scale.y) * 0.25), 0, 2)
	idle_sound_timer = 5.0 + randf() * 10.0

func _process(delta: float) -> void:
	invincibility_time -= delta
	
	if invincibility_time < 0:
		invincibility_time = 0

	if attacking:
		viking.take_damage(damage)

	idle_sound_timer -= delta
	if idle_sound_timer <= 0.0 and !idle_audio_player.playing:
		idle_audio_player.play()
		idle_sound_timer = 5.0 + randf() * 10.0
	
	if burning_ticks > 0:
		burning_timer -= delta
		if burning_timer < 0:
			var fire_level = GameManager.viking_state.skills.get("axe_fire", 0)
			take_damage(fire_level * 2)
			burning_ticks -= 1
			burning_timer = 1.5 / fire_level
		fire_particles_2d.emitting = true
	else:
		fire_particles_2d.emitting = false

	if frozen_timer > 0.0:
		modulate = Color(0.75, 0.75, 1.0) * original_modulate
		frozen_timer -= delta
	else:
		modulate = original_modulate

func _physics_process(_delta: float) -> void:
	var direction_to_viking = (viking.position - position).normalized()

	if direction_to_viking.x < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false

	var actual_speed: float = speed

	if frozen_timer > 0.0:
		var frost_level = GameManager.viking_state.skills.get("axe_frost", 0)
		actual_speed *= 1.0 - frost_level * 0.25

	velocity = direction_to_viking * actual_speed
	move_and_slide()
	update_animation_state()

func _on_hurt_box_body_entered(body:Node2D) -> void:
	if body is Viking:
		attacking = true

func _on_hurt_box_body_exited(body: Node2D) -> void:
	if body is Viking:
		attacking = false

func take_damage(amount: float) -> void:
	if invincibility_time > 0:
		return
	invincibility_time = 0.5
	
	health -= amount

	if health <= 0:
		spawn_experience()
		collision_shape.set_deferred("disabled", true)
		hurt_box.set_deferred("monitoring", false)
		visible = false
	
	on_hit_audio_player.play()

func die() -> void:
	queue_free() 

func update_animation_state():
	if (velocity.length() > 0):
		animation_state_machine.travel("Walk")
	else:
		animation_state_machine.travel("Idle")


func _on_on_hit_audio_stream_player_2d_finished() -> void:
	if health <= 0:
		die()

func spawn_experience() -> void:
	print(self.global_position)
	print(GameManager.viking.global_position)
	print("Spawning experience for enemy with reward: ", reward_experience)
	var experience_scene = load("res://viking/experience.tscn") as PackedScene
	var experience: Experience = experience_scene.instantiate()
	experience.value = reward_experience
	experience.global_position = global_position
	get_parent().add_child(experience)
