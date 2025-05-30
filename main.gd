extends Node2D

var collageMode = true
var currentCollages = []

@onready var currentLevelPath = 'res://fases/fase_2.tscn'

var level

func _ready():
	$Menu.show()
	$collageScreen.hide()
	
	level = load(currentLevelPath).instantiate()
	add_child(level)
	level.hide()
	
	
func _on_menu_start_game():
	$Menu.hide()
	level.show()
	level.start_animations()
	currentCollages = level.levelCollages
	
	$collageScreen.createCollages()
	$collageScreen.show()
	
	#pausa o jogo
	level.get_node("Player").process_mode = Node.PROCESS_MODE_DISABLED
	
func collageEnded():
	#transição do zoom
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property($Camera2D,"zoom",Vector2(1.0, 1.0), 0.5)
	
	for collage in $collageScreen/collagesGroup.get_children():
		collage.collageMode = false
		
	#despausa
	level.get_node("Player").process_mode = Node.PROCESS_MODE_INHERIT
