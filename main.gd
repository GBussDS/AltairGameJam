extends Node2D

var collageMode = true

func _ready():
	$Menu.show()
	$Inicio.hide()
	$collageScreen.hide()
	
func _on_menu_start_game():
	$Menu.hide()
	$Inicio.show()
	$Inicio.start_animations()
	$collageScreen.show()
	
	#pausa o jogo
	$Inicio.process_mode = Node.PROCESS_MODE_DISABLED
	
func collageEnded():
	$collageScreen.hide()
	
	#transição do zoom
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property($Camera2D,"zoom",Vector2(1.0, 1.0), 0.5)
	
	var collages = $collageScreen.get_node('collagesGroup').duplicate()
	collages.global_position += $collageScreen.global_position
	$Inicio.add_child(collages)
	
	for collage in collages.get_children():
		collage.collageMode = false
		
	#despausa
	$Inicio.process_mode = Node.PROCESS_MODE_INHERIT
