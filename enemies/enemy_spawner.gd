extends Node
class_name EnemySpawner

@export var spawn_list: Array[SpawnEntry] = []
@export var spawn_interval: float = 2.0  # Time in seconds between spawns
@export var spawn_timer = 0.0
@export var game_time = 0.0

@export var minimum_spawn_distance: float = 256.0
@export var maximum_spawn_distance: float = 768.0 

@export var objects_root: Node2D

const spawn_quadrants = [
	Vector2(1, 1),
	Vector2(-1, 1), 
	Vector2(1, -1),  
	Vector2(-1, -1), 
	Vector2(0, 1),
	Vector2(0, -1),
	Vector2(1, 0), 
	Vector2(-1, 0)
]

func _ready() -> void:
	GameManager.enemy_spawner = self

func _process(delta: float) -> void:
	game_time += delta
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_enemy()
		spawn_timer = 0.0

func spawn_enemy() -> void:
	var spawn_index = int(game_time / 60) % spawn_list.size()
	var spawn_entry = spawn_list[spawn_index]
	var enemy_scene = spawn_entry.scene
	var enemy: Enemy = enemy_scene.instantiate()
	enemy.health = spawn_entry.health
	enemy.damage = spawn_entry.damage
	enemy.speed = spawn_entry.speed
	enemy.modulate = spawn_entry.modulate
	enemy.scale = Vector2(spawn_entry.scale, spawn_entry.scale)
	enemy.reward_experience = spawn_entry.experience

	var spawn_direction = spawn_quadrants[randi() % spawn_quadrants.size()]

	enemy.global_position = Vector2(
		GameManager.viking.global_position.x + (minimum_spawn_distance * spawn_direction.x) + randf() * (maximum_spawn_distance - minimum_spawn_distance) * spawn_direction.x, 
		GameManager.viking.global_position.y + + (minimum_spawn_distance * spawn_direction.y) + randf() * (maximum_spawn_distance - minimum_spawn_distance) * spawn_direction.y)
	objects_root.add_child(enemy)

func respawn_enemy(enemy: Enemy) -> void:
	var spawn_direction = spawn_quadrants[randi() % spawn_quadrants.size()]

	enemy.global_position = Vector2(
		GameManager.viking.global_position.x + (minimum_spawn_distance * spawn_direction.x) + randf() * (maximum_spawn_distance - minimum_spawn_distance) * spawn_direction.x, 
		GameManager.viking.global_position.y + + (minimum_spawn_distance * spawn_direction.y) + randf() * (maximum_spawn_distance - minimum_spawn_distance) * spawn_direction.y)
