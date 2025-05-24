extends CharacterBody2D
class_name Viking

@export var base_move_speed = 48

@export var move_direction: Vector2 = Vector2.ZERO
@export var look_direction: Vector2 = Vector2.ZERO

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")

@onready var body = %Body
@onready var main_hand: Node2D = %MainHand
@onready var main_arm: Node2D = %MainArm

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
