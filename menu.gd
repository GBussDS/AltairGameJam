extends Control

func _on_play_button_up():
	get_tree().change_scene_to_file('game.tscn')

func _on_config_button_up():
	pass

func _on_quit_button_up():
	get_tree().quit()
