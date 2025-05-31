extends CenterContainer

signal return_to_menu
signal retry_level


func _on_menu_pressed() -> void:
    emit_signal("return_to_menu")

func _on_retry_pressed() -> void:
    emit_signal("retry_level")
