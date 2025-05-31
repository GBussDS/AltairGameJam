extends Node2D

var collageMode = false
var currentCollages = []

@onready var currentLevelPath = 'res://fases/fase_6.tscn'

var level
var numDeaths = 0

func _ready():
	$Menu.show()
	$collageScreen.hide()
	
	instantiate_level()
	
func _on_menu_start_game():
	$Menu.hide()
	$DeathCounter.show()
	level.show()
	level.process_mode = Node.PROCESS_MODE_INHERIT
	level.start_animations()
	currentCollages = level.levelCollages
	
	$collageScreen.createCollages()
	$collageScreen.show()
	$collageScreen.is_dragging = -1
	collageMode = true
	
	#pausa o jogo
	level.get_node("Player").process_mode = Node.PROCESS_MODE_DISABLED
	
func instantiate_level():
	if level:
		level.queue_free()
	
	level = load(currentLevelPath).instantiate()
	level.player_death.connect(_on_player_death)
	add_child(level)
	level.hide()

func collageEnded():
	collageMode = false
	transition_in()
	
	for collage in $collageScreen/collagesGroup.get_children():
		collage.collageMode = false
		
	#despausa
	level.get_node("Player").process_mode = Node.PROCESS_MODE_INHERIT

func _on_player_death():
	numDeaths += 1
	$DeathCounter.text = "Mortes: " + str(numDeaths)
	# instantiate_level()
	

func _on_pause_menu_return_to_menu() -> void:
	$PauseMenu.hide()
	$Menu.show()

func _on_pause_menu_retry_level() -> void:
	$PauseMenu.hide()
	_on_menu_start_game()
	level.reset_player()
	level.process_mode = Node.PROCESS_MODE_INHERIT

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
			transition_out()
			$collageScreen.hide()
			$DeathCounter.hide()
			if level:
				level.hide()
				level.process_mode = Node.PROCESS_MODE_DISABLED

func resume_game():
	$PauseMenu.hide()
	$DeathCounter.show()
	$collageScreen.show()
	if not collageMode:
		transition_in()
	if level:
		level.show()
		level.process_mode = Node.PROCESS_MODE_INHERIT

func _on_pause_menu_resume_game() -> void:
	resume_game()
