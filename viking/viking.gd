extends CharacterBody2D
class_name Viking

@export var base_move_speed = 48
@export var health: int = 10

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

func _process(delta: float) -> void:
	invincibility_time -= delta
	if invincibility_time < 0:
		invincibility_time = 0

func _physics_process(_delta: float):
	var flip = look_direction.x < 0
	var current_move_speed = base_move_speed

	if animation_state_machine.get_current_node() == "Attack":
		current_move_speed = 0
		main_arm.rotation = look_direction.angle() if !flip else look_direction.angle() + PI
	else:
		main_arm.rotation = 0

	velocity = move_direction * current_move_speed

	body.scale.x = -1 if flip else 1    

	move_and_slide()
	update_animation_state()

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
	print("Throwing axe!")
	if has_axe:
		has_axe = false
		axe_sprite.visible = false
		var axe_scene = load("res://axe/axe.tscn") as PackedScene
		var thrown_axe: Axe = axe_scene.instantiate()
		thrown_axe.global_position = main_hand.global_position
		thrown_axe.linear_velocity = look_direction * 500
		thrown_axe.direction = 1 if look_direction.x >= 0 else -1
		thrown_axe.rotation = main_hand.global_rotation
		#thrown_axe.angular_velocity = 100
		get_parent().add_child(thrown_axe)
	else:
		print("No axe to throw!")

func pick_up_axe():
	if !has_axe:
		has_axe = true
		axe_sprite.visible = true
	else:
		print("Already have an axe!")

func take_damage(damage: int) -> void:
	if invincibility_time > 0:
		return
	invincibility_time = 0.5
	health -= damage
	if health <= 0:
		die()

func die() -> void:
	print("Viking has died!")
