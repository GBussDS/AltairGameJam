extends Control

signal start_game


func _on_play_button_pressed():
	emit_signal("start_game")

func _on_config_button_pressed():
	pass

func _on_quit_button_pressed():
	get_tree().quit()
