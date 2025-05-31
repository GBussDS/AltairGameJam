extends Control

signal start_game


func _on_play_button_pressed():
	start_game.emit()

func _on_config_button_pressed():
	$start.hide()
	$Settings.show()

func _on_quit_button_pressed():
	get_tree().quit()

func _on_fase_button_up(level):
	get_parent().playLevel(level)

func show_menu():
	$Settings.hide()
	$start.show()
