extends Resource
class_name VikingState

@export var health: float = 100
@export var base_max_health: float = 100
@export var base_move_speed: float = 64.0
@export var base_xp_radius: float = 64.0
@export var base_shield = 0.0
@export var base_axe_throw_speed: float = 512.0  
@export var base_axe_damage: float = 10.0
@export var base_axe_ricochet_multiplier: float = 0.5
@export var skills: Dictionary[String, int] = {}
@export var total_xp: int = 0
@export var spent_xp: int = 0

var max_health: float:
	get:
		return base_max_health + skills.get("max_health", 0) * 30

var move_speed: float:
	get:
		return base_move_speed + skills.get("movement_speed", 0) * 24

var shield: float:
	get:
		return base_shield + skills.get("shield", 0)

var xp_radius: float:
	get:
		return base_xp_radius + (skills.get("xp_radius", 0) / 5.0) * 192

var axe_throw_speed: float:
	get:
		return base_axe_throw_speed + (skills.get("axe_range", 0) / 3.0) * 512

var axe_damage: float:
	get:
		return 10 + skills.get("axe_damage", 0) * 5

var axe_ricochet_multiplier: float:
	get:
		return base_axe_ricochet_multiplier + skills.get("axe_ricochet", 0) * 0.5

var current_xp: int:
	get:
		return total_xp - spent_xp

func start() -> void:
	health = max_health
	state_changed.emit()

func add_xp(amount: int) -> void:
	total_xp += amount
	state_changed.emit()

func spend_xp(amount: int) -> void:
	if amount <= current_xp:
		spent_xp += amount
		state_changed.emit()
	else:
		print("Not enough XP to spend!")

func take_damage(damage: float) -> void:
	health -= max(damage - shield, 0)
	state_changed.emit()

signal state_changed