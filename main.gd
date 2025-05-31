extends Node2D

var collageMode = false
var currentCollages = []

var currentLevel = 0
@export var levels: Array[PackedScene] = []

var level: Node2D
		
@onready var currentLevelPath = 'res://fases/fase_6.tscn'

var numDeaths = 0

func _ready():
	$Menu.show()
	$collageScreen.hide()
	
	
func _on_menu_start_game():
	$Menu/start.hide()
	$Menu/fases.show()
	
func collageEnded():
	collageMode = false
	transition_in()
	
	for collage in $collageScreen/collagesGroup.get_children():
		collage.collageMode = false
		
	#despausa
	level.get_node("Player").process_mode = Node.PROCESS_MODE_INHERIT

func nextLevel():
	print('sss')
	
	currentLevel += 1
	if currentLevel >= len(levels):
		currentLevel = 0
	
	playLevel(currentLevel + 1)
	
func playLevel(levelNum):
	transition_out()
	
	$Menu.hide()
	
	currentLevel = levelNum - 1
	if level:
		level.queue_free()
	level = levels[currentLevel].instantiate()
	level.player_death.connect(_on_player_death)
	add_child(level)
	
	level.start_animations()
	
	currentCollages = level.levelCollages
	
	collageMode = true
	$collageScreen.createCollages()
	$collageScreen.show()
	$collageScreen.is_dragging = -1
	print('b')
	
	#pausa o player
	level.get_node("Player").process_mode = Node.PROCESS_MODE_DISABLED
	
	if level is Node2D:
		print("b")
	
	$DeathCounter.show()

func _on_player_death():
	numDeaths += 1
	$DeathCounter.text = "Mortes: " + str(numDeaths)
	# instantiate_level()

func _on_pause_menu_resume_game() -> void:
	resume_game()

func _on_pause_menu_retry_level() -> void:
	$PauseMenu.hide()
	playLevel(currentLevel + 1)

func _on_pause_menu_return_to_menu() -> void:
	$PauseMenu.hide()
	$Menu/start.show()
	$Menu/fases.hide()
	$Menu.show()

func transition_in():
	#transição do zoom
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property($Camera2D, "zoom", Vector2(1.0, 1.0), 0.5)

func transition_out():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property($Camera2D, "zoom", Vector2(0.65, 0.65), 0.5)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not $Menu.is_visible():
		if $PauseMenu.is_visible():
			resume_game()
		else:
			$PauseMenu.show()
			transition_in()
			$collageScreen.hide()
			$DeathCounter.hide()
			if level:
				level.hide()
				level.process_mode = Node.PROCESS_MODE_DISABLED

func resume_game():
	$PauseMenu.hide()
	$DeathCounter.show()
	$collageScreen.show()
	if collageMode:
		transition_out()
	if level:
		level.show()
		level.process_mode = Node.PROCESS_MODE_INHERIT
