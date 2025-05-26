@tool
extends TextureButton
class_name SkillButton

@export var title: String
@export var description: String
@export var level_cost: Array[int] = []
@export var skill_id: String
@export var icon: Texture2D
@export var skill_color: Color = Color(1, 1, 1)

@onready var icon_texture_rect: TextureRect = $IconTextureRect
@onready var label: Label = $Label
@onready var description_panel: Panel = $Panel
@onready var description_label: RichTextLabel = $Panel/DescriptionLabel
@onready var inner_line_2d: Line2D = $InnerLine2D
@onready var outer_line_2d: Line2D = $OuterLine2D

var max_level: int:
	get:
		return level_cost.size()

var skill_level: int:
	get:
		return get_viking_skill_level()

func get_viking_skill_level() -> int:
	if Engine.is_editor_hint():
		return 0 
	return GameManager.viking_state.skills.get(skill_id, 0)

func _ready() -> void:
	render_skill()

func render_skill() -> void:
	label.text = str(skill_level) + "/" + str(max_level)

	print(description_label)

	var description_label_text = "[color=\"" + skill_color.to_html() + "\"][b]" + title + "[/b][/color]";
	description_label_text += "\n[i]" + description + "[/i]\n"
	
	if skill_level < max_level:
		description_label_text += "[b]Next level: " + str(level_cost[skill_level]) + " XP[/b]"
	
	description_label.text = description_label_text

	icon_texture_rect.texture = icon

	var parent_skill_button: Control = get_parent()
	if parent_skill_button is SkillButton:
		inner_line_2d.clear_points()
		inner_line_2d.add_point(Vector2.ZERO + size / 2)
		inner_line_2d.add_point(-position + parent_skill_button.size / 2)
		outer_line_2d.clear_points()
		outer_line_2d.add_point(Vector2.ZERO + size / 2)
		outer_line_2d.add_point(-position + parent_skill_button.size / 2)
		
		if parent_skill_button.skill_level < 1:
			disabled = true
			icon_texture_rect.self_modulate = Color(0.5, 0.5, 0.5)
		else:
			disabled = false
			icon_texture_rect.self_modulate = Color(1, 1, 1)

	if skill_level > 0:
		inner_line_2d.default_color = Color(0.138, 0.575, 0.81)
		outer_line_2d.default_color = Color(0.384, 0.424, 0.451)
		self_modulate = Color(1,1,1)
	else:
		self_modulate = Color(0.4,0.4,0.4)
		inner_line_2d.default_color = Color(0.22, 0.239, 0.263)
		outer_line_2d.default_color = Color(0.176, 0.192, 0.208)

func _on_pressed() -> void:
	if skill_level >= max_level or level_cost[skill_level] > GameManager.viking_state.current_xp:
		return
	GameManager.viking_state.spend_xp(level_cost[skill_level])
	GameManager.viking_state.skills[skill_id] = clampi(get_viking_skill_level() + 1, 0, max_level)
	render_skill_recursive()


func _on_editor_state_changed() -> void:
	render_skill()


func _on_mouse_entered() -> void:
	description_panel.visible = true


func _on_mouse_exited() -> void:
	description_panel.visible = false

func render_skill_recursive() -> void:
	render_skill()
	for child in get_children():
		if child is SkillButton:
			child.render_skill_recursive()
