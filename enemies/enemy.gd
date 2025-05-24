extends CharacterBody2D
class_name Enemy

@export var health = 1
@export var damage = 1
@export var speed = 10

@export var invincibility_time: float = 0

@onready var viking = %Viking

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")

@onready var sprite = $Sprite2D

var attacking = false

func _process(delta: float) -> void:
	invincibility_time -= delta
	
	if invincibility_time < 0:
		invincibility_time = 0

	if attacking:
		viking.take_damage(damage)

func _physics_process(_delta: float) -> void:
	var direction_to_viking = (viking.position - position).normalized()

	if direction_to_viking.x < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false

	velocity = direction_to_viking * speed
	move_and_slide()
	update_animation_state()

func _on_hurt_box_body_entered(body:Node2D) -> void:
	if body is Viking:
		attacking = true

func _on_hurt_box_body_exited(body: Node2D) -> void:
	if body is Viking:
		attacking = false

func take_damage(amount: int) -> void:
	if invincibility_time > 0:
		return
	invincibility_time = 0.5
	health -= amount
	if health <= 0:
		die()

func die() -> void:
	queue_free() 

func update_animation_state():
	if (velocity.length() > 0):
		animation_state_machine.travel("Walk")
	else:
		animation_state_machine.travel("Idle")
