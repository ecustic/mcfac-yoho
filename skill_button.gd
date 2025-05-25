extends TextureButton
class_name SkillNode

signal skill_activated(skill_name: String)

@export var skill_name: String = "Skill name:"
@export var skill_description: String = "Skill description."
@export var skill_levels: int

@onready var panel = $Panel
@onready var label = $MarginContainer/Label
@onready var line_2d = $Line2D
@onready var skill_name_label = $ToolTipPanel/VBoxContainer/SkillNameLabel
@onready var skill_description_label = $ToolTipPanel/VBoxContainer/SkillDescriptionLabel

func _ready():
	labels_not_visible()
	connect("mouse_entered", _on_mouse_entered)
	connect("mouse_exited", _on_mouse_exited)
	label.text = "0/" + str(skill_levels)
	
	if get_parent() is SkillNode:
		line_2d.add_point(global_position + size / 2)
		line_2d.add_point(get_parent().global_position + size / 2)

var level: int = 0:
	set(value):
		level = value
		label.text = str(level) + ("/") +str(skill_levels)

func _on_pressed() -> void:
	level = min(level +1, skill_levels)
	panel.show_behind_parent = true
	
	var skill_tree = get_tree().get_first_node_in_group("SkillTree")
	skill_tree.setUnlock(skill_name, level)
	self.self_modulate = Color(1, 1, 1)
	
	emit_signal("skill_activated", skill_name)
	
	line_2d.default_color = Color(0.242, 0.712, 0.0)
	
	var skills = get_children()
	for skill in skills:
		if skill is SkillNode and level == skill_levels:
			skill.disabled = false


func labels_not_visible():
	skill_name_label.visible = false
	skill_description_label.visible = false

func labels_visible():
	skill_name_label.visible = true
	skill_description_label.visible = true
	
func _on_mouse_entered():
	skill_name_label.text = skill_name
	skill_description_label.text = skill_description
	labels_visible()
	
func _on_mouse_exited():
	labels_not_visible()
