extends Node
class_name WorldGenerator

const WORLD_SIZE = Vector2(512 * 16, 512 * 16)
const SPAWN_GRID_SIZE = 8 * 16
const SNOW_HEIGHT = 180 * 16
const GRASS_HEIGHT = 380 * 16

@export var world_seed: int = 0
@export var objects_root: Node2D

func _ready() -> void:
	if world_seed == 0:
		world_seed = randi()  # Generate a random seed if not set
	generate_world()

func generate_world() -> void:
	var object_scenes = [
		{
			scene = load("res://world/objects/tree_snow.tscn") as PackedScene,
			probability = 0.33,
			min_y = 0,
			max_y = SNOW_HEIGHT
		},
		{ 
			scene = load("res://world/objects/rock_snow.tscn") as PackedScene,
			probability = 0.33,
			min_y = 0,
			max_y = SNOW_HEIGHT
		},
		{ 
			scene = load("res://world/objects/small_rock_snow.tscn") as PackedScene,
			probability = 0.33,
			min_y = 0,
			max_y = SNOW_HEIGHT
		},
		{
			scene = load("res://world/objects/tree.tscn") as PackedScene,
			probability = 0.33,
			min_y = SNOW_HEIGHT,
			max_y = WORLD_SIZE.y
		},
		{ 
			scene = load("res://world/objects/rock.tscn") as PackedScene,
			probability = 0.33,
			min_y = SNOW_HEIGHT,
			max_y = WORLD_SIZE.y
		},
		{ 
			scene = load("res://world/objects/small_rock.tscn") as PackedScene,
			probability = 0.33,
			min_y = SNOW_HEIGHT,
			max_y = WORLD_SIZE.y
		}
	]

	var rng = RandomNumberGenerator.new()
	rng.seed = world_seed

	for x in range(0, WORLD_SIZE.x, SPAWN_GRID_SIZE):
		for y in range(0, WORLD_SIZE.y, SPAWN_GRID_SIZE):
			var eligible_objects = object_scenes.filter(func(obj):
				return obj.min_y <= y and y <= obj.max_y
			)
			if eligible_objects.size() == 0:
				continue
			
			var probability_sum = 0.0
			for obj in eligible_objects:
				probability_sum += obj.probability
			
			var probability_multiplier = 1.0 / probability_sum if probability_sum > 1.0 else 1.0
			var random_value = rng.randf()
			var cumulative_probability = 0.0

			for obj in eligible_objects:
				var adjusted_probability = obj.probability * probability_multiplier
				if random_value > cumulative_probability and random_value <= cumulative_probability + adjusted_probability:
					var instance = obj.scene.instantiate()
					instance.position = Vector2(x + (rng.randf() - 0.5) * SPAWN_GRID_SIZE, y + (rng.randf() - 0.5) * SPAWN_GRID_SIZE)
					objects_root.add_child(instance)
					break
				cumulative_probability += adjusted_probability
