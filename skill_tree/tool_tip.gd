extends TextureButton

@onready var tooltip_label = $TooltipLabel

func _ready():
	connect("mouse_entered", self._on_mouse_entered)
	connect("mouse_exited", self._on_mouse_exited)
	
func _on_mouse_entered():
	tooltip_label.visible = true
	
func _on_mouse_exited():
	tooltip_label.visible = false
