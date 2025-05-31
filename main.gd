extends Node2D

var collageMode = true
var currentCollages = []

var currentLevel = 0
@export var levels: Array[PackedScene] = []

var level: Node2D
		
func _ready():
	$Menu.show()
	$collageScreen.hide()
	
func _on_menu_start_game():
	$Menu/start.hide()
	$Menu/fases.show()
	
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

func nextLevel():
	print('sss')
	$collageScreen.hide()
	level.free()
	
	currentLevel += 1
	if currentLevel >= len(levels):
		currentLevel = 0
		
	level = levels[currentLevel].instantiate()
	add_child(level)
		
	currentCollages = level.levelCollages
	
	for child in $collageScreen/collagesGroup.get_children():
		child.free()
		
	$collageScreen.createCollages()
	
	$collageScreen.show()
	
	#pausa o jogo
	level.get_node("Player").process_mode = Node.PROCESS_MODE_DISABLED
	level.start_animations()
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property($Camera2D,"zoom",Vector2(0.65, 0.65), 0.5)
	
	$collageScreen.is_dragging = -1
	
func playLevel(levelNum):
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property($Camera2D,"zoom",Vector2(0.65, 0.65), 0.5)
	
	$Menu.hide()
	
	currentLevel = levelNum - 1
	level = levels[currentLevel].instantiate()
	add_child(level)
	
	level.start_animations()
	
	currentCollages = level.levelCollages
	
	$collageScreen.createCollages()
	$collageScreen.show()
	print('b')
	
	#pausa o player
	level.get_node("Player").process_mode = Node.PROCESS_MODE_DISABLED
	
	if level is Node2D:
		print("b")
