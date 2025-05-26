extends Control

@onready var xp_label: Label = %XPLabel
@onready var health_progress_bar: ProgressBar = %HealthProgressBar

func update_ui() -> void:
	if GameManager.viking:
		xp_label.text = str(GameManager.viking_state.current_xp)
		health_progress_bar.value = GameManager.viking_state.health
		health_progress_bar.max_value = GameManager.viking_state.max_health

func _ready() -> void:
	update_ui()
	GameManager.viking_state.state_changed.connect(update_ui)
