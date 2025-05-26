extends Node

var world_root: Node2D
var ui_root: CanvasLayer

@onready var viking_scene: PackedScene = preload("res://viking/viking.tscn")
@onready var world_scene: PackedScene = preload("res://world/world.tscn")
@onready var main_menu_scene: PackedScene = preload("res://ui/main_menu.tscn")
@onready var hud_scene: PackedScene = preload("res://ui/hud.tscn")

var viking_state: VikingState = VikingState.new()

@export var viking: Viking = null
@export var world: Node2D = null
@export var main_menu: Control = null
@export var hud: Control = null
@export var enemy_spawner: EnemySpawner = null

func _ready() -> void:
	world_root = get_node("/root/Game/WorldRoot") as Node2D
	ui_root = get_node("/root/Game/UIRoot") as CanvasLayer
	show_main_menu()

func start_game() -> void:
	world = world_scene.instantiate() as Node2D
	viking = viking_scene.instantiate() as Viking
	viking.position = Vector2(256 * 16 - 8, 256 * 16 - 8)
	viking_state.start()
	viking.state = viking_state
	enemy_spawner = world.get_node("EnemySpawner") as EnemySpawner
	
	var entities = world.get_node("Entities")
	entities.add_child(viking)
	main_menu.queue_free()

	hud = hud_scene.instantiate() as Control

	world_root.add_child(world)
	ui_root.add_child(hud)

func show_main_menu() -> void:
	if world:
		world.process_mode = Node.PROCESS_MODE_DISABLED
		world.queue_free()

	if hud:
		hud.queue_free()

	world = null
	viking = null
	enemy_spawner = null
	hud = null

	main_menu = main_menu_scene.instantiate() as Control
	ui_root.add_child(main_menu)
