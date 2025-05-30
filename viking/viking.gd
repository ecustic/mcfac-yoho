extends CharacterBody2D
class_name Viking

@export var state: VikingState

@export var invincibility_time: float = 0

@export var move_direction: Vector2 = Vector2.ZERO
@export var look_direction: Vector2 = Vector2.ZERO

@export var has_axe: bool = true

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")

@onready var body = %Body
@onready var main_hand: Node2D = %MainHand
@onready var main_arm: Node2D = %MainArm

@onready var axe_sprite: Sprite2D = %MainHand/AxeSprite

@onready var axe_throw_audiostream_player: AudioStreamPlayer2D = $AxeThrowAudioStreamPlayer2D
@onready var on_hit_audio_player: AudioStreamPlayer2D = $OnHitAudioStreamPlayer2D

@onready var xp_collect_area: Area2D = $XPCollectArea

func _ready() -> void:
	GameManager.viking = self
	var xp_collision_shape = xp_collect_area.get_node("CollisionShape2D") as CollisionShape2D 
	var xp_collision_circle_shape = xp_collision_shape.shape as CircleShape2D
	xp_collision_circle_shape.radius = GameManager.viking_state.xp_radius

	if GameManager.viking_state.skills.get("axe_fire", 0) > 0:
		(axe_sprite.get_node("FireParticles2D") as CPUParticles2D).emitting = true
	if GameManager.viking_state.skills.get("axe_frost", 0) > 0:
		axe_sprite.self_modulate = Color(0.75, 0.75, 1.0)

func _process(delta: float) -> void:
	invincibility_time -= delta
	if invincibility_time < 0:
		invincibility_time = 0

func _physics_process(_delta: float):
	var mouse_axis = (get_global_mouse_position() - global_position)

	if animation_state_machine.get_current_node() != "Attack":
		look_direction = mouse_axis.normalized()

	var flip = look_direction.x < 0
	var current_move_speed = state.move_speed

	move_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()

	if animation_state_machine.get_current_node() == "Attack":
		current_move_speed = 0
		main_arm.rotation = look_direction.angle() if !flip else look_direction.angle() + PI
	else:
		main_arm.rotation = 0

	velocity = move_direction * current_move_speed

	body.scale.x = -1 if flip else 1    

	move_and_slide()

	if position.x < 8:
		position.x = 8
	elif position.x > 512 * 16 - 8:
		position.x = 512 * 16 - 8
	if position.y < 8:
		position.y = 8
	elif position.y > 512 * 16 - 8:
		position.y = 512 * 16 - 8

	update_animation_state()

func _input(event: InputEvent) -> void:
	if event.is_action_released("attack") and has_axe and animation_state_machine.get_current_node() != "Attack": 
		animation_state_machine.start("Attack", true)
	
	if event.is_action_pressed("ui_cancel"):
		GameManager.show_main_menu()

func update_animation_state():
	if (velocity.length() > 0):
		animation_state_machine.travel("Walk")
	else:
		animation_state_machine.travel("Idle")

	if has_axe:
		axe_sprite.visible = true
	else:
		axe_sprite.visible = false

func throw_axe():
	if has_axe:
		has_axe = false
		axe_sprite.visible = false
		var axe_scene = load("res://axe/axe.tscn") as PackedScene
		var thrown_axe: Axe = axe_scene.instantiate()
		thrown_axe.global_position = main_hand.global_position
		thrown_axe.linear_velocity = look_direction * state.axe_throw_speed
		thrown_axe.direction = 1 if look_direction.x >= 0 else -1
		thrown_axe.rotation = main_hand.global_rotation
		get_parent().add_child(thrown_axe)
		axe_throw_audiostream_player.play()
	else:
		print("No axe to throw!")

func pick_up_axe():
	if !has_axe:
		has_axe = true
		axe_sprite.visible = true
	else:
		print("Already have an axe!")

func take_damage(damage: float) -> void:
	if invincibility_time > 0:
		return
	invincibility_time = 0.5
	state.take_damage(damage)
	on_hit_audio_player.play()
	if state.health <= 0:
		die()

func die() -> void:
	GameManager.show_main_menu()

func _on_enemy_spawn_area_body_exited(exited_body:Node2D) -> void:
	if exited_body is Enemy:
		GameManager.enemy_spawner.respawn_enemy(exited_body as Enemy)


func _on_xp_collect_area_area_entered(area: Area2D) -> void:
	if area is Experience:
		var experience: Experience = area as Experience
		experience.follow_viking(self)
		
