extends Resource
class_name VikingState

@export var health: int = 10
@export var max_health: int = 10
@export var move_speed: float = 48.0
@export var axe_throw_speed: float = 500.0  
@export var skills: Dictionary[String, int] = {}

func start() -> void:
	health = max_health
