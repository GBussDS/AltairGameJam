extends Control

signal start_game


func _on_play_button_up():
	emit_signal("start_game")

func _on_config_button_up():
	pass

func _on_quit_button_up():
	get_tree().quit()
