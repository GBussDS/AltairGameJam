extends CenterContainer

signal return_to_menu
signal retry_level
signal resume_game

func _on_menu_pressed() -> void:
	return_to_menu.emit()

func _on_retry_pressed() -> void:
	retry_level.emit()

func _on_resume_pressed() -> void:
	resume_game.emit()
