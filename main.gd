extends Node2D

var collageMode = true

func _ready():
	$Menu.show()
	$Inicio.hide()
	$collageScreen.hide()
	
func _on_menu_start_game():
	$Menu.hide()
	$Inicio.show()
	$collageScreen.show()
	
	#pausa o jogo
	$Inicio.process_mode = Node.PROCESS_MODE_DISABLED
	
func collageEnded():
	$collageScreen.hide()
	
	var collages = $collageScreen.get_node('collagesGroup').duplicate()
	$Inicio.add_child(collages)
	
	for collage in collages.get_children():
		collage.collageMode = false
		
	#despausa
	$Inicio.process_mode = Node.PROCESS_MODE_INHERIT
