extends Node2D

const LEVEL_BUTTON = preload("res://level_button.tscn")
const COLLAGE_SHADER = preload("res://shaders/collage.gdshader")

const MAX_LEVELS_PER_ROW = 5
const TRANSITION_DURATION = 1
const CAMERA_DEFAULT_ZOOM = 1.0
const CAMERA_ZOOM_OUT = 0.65

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

	# Lógica para criar botões de níveis automaticamente
	var numLevels = levels.size()
	var levelsPerRow = numLevels / ceil(numLevels / float(MAX_LEVELS_PER_ROW))
	var currentRow = 0
	var currentHBox
	for i in range(numLevels):
		# Um HBoxContainer para cada linha de níveis
		if i >= currentRow * levelsPerRow:
			currentRow += 1
			currentHBox = HBoxContainer.new()
			currentHBox.name = "Row" + str(currentRow)
			currentHBox.add_theme_constant_override("separation", 30)
			$Menu/fases/CenterContainer/VBoxContainer.add_child(currentHBox)
		# Cria o botão de nível
		var levelButton = LEVEL_BUTTON.instantiate()
		levelButton.name = "Level" + str(i + 1)
		levelButton.get_node("Label").text = str(i + 1)
		levelButton.pressed.connect(transition_to_level.bind(i + 1))

		# Configura os shaders
		var buttonShadow = levelButton.get_node("Shadow")
		buttonShadow.material.set_shader_parameter("screen_center", Vector2(get_viewport_rect().size.x * 0.5, 0))
		var buttonBackground = levelButton.get_node("Background")
		var randomRotation = randf_range(0, 360.0)
		var buttonCenter = levelButton.size / 2
		# Rotaciona o background e a sombra ao redor do centro do botão
		buttonBackground.rotation_degrees = randomRotation
		buttonBackground.position = buttonCenter - Vector2(buttonCenter.x, buttonCenter.y).rotated(deg_to_rad(randomRotation))
		buttonShadow.rotation_degrees = randomRotation
		buttonShadow.position = buttonCenter - Vector2(buttonCenter.x, buttonCenter.y).rotated(deg_to_rad(randomRotation))
		levelButton.material = ShaderMaterial.new()
		levelButton.material.shader = COLLAGE_SHADER
		levelButton.material.set_shader_parameter("intensityX", 5.0)
		levelButton.material.set_shader_parameter("intensityY", 5.0)
		var random_delay = randf_range(0.0, 2.0)
		levelButton.material.set_shader_parameter("timeDelay", random_delay)
		var random_seed = randi() % 1000
		levelButton.material.set_shader_parameter("seed", random_seed)

		currentHBox.add_child(levelButton)
	
	animate_screen_transition()

func animate_screen_transition(block: bool = false):
	var progress = 0
	if block:
		progress = 1.0
		$Camera2D/TransitionScreen.show()
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Camera2D/TransitionScreen.material, "shader_parameter/progress", progress, TRANSITION_DURATION)

	if not block:
		tween.tween_callback($Camera2D/TransitionScreen.hide)
	return tween

func transition_into(callable: Callable):
	var tween = animate_screen_transition(true)
	tween.tween_callback(callable)
	tween.tween_callback(animate_screen_transition)
	
func _on_menu_start_game():
	transition_into(show_level_buttons)

func show_level_buttons():
	$Menu/start.hide()
	$Menu/fases.show()
	
func collageEnded():
	collageMode = false
	camera_transition_in()
	
	for collage in $collageScreen/collagesGroup.get_children():
		collage.collageMode = false
		# Verifica se a colagem é um RigidBody2D
		if collage is RigidBody2D:
			collage.freeze = false
		
	#despausa
	level.get_node("Player").process_mode = Node.PROCESS_MODE_INHERIT

func nextLevel():
	print('sss')
	
	currentLevel += 1
	if currentLevel >= len(levels):
		currentLevel = 0
	
	transition_to_level(currentLevel + 1)

func transition_to_level(levelNum: int):
	camera_transition_out()
	transition_into(playLevel.bind(levelNum))
	
func playLevel(levelNum):
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
	$collageScreen.process_mode = Node.PROCESS_MODE_INHERIT
	print('b')
	
	#pausa o player
	level.get_node("Player").process_mode = Node.PROCESS_MODE_DISABLED
	
	if level is Node2D:
		print("b")
	
	$DeathCounter.show()

func _on_player_death():
	numDeaths += 1
	$DeathCounter.text = "Deaths: " + str(numDeaths)
	# instantiate_level()

func _on_pause_menu_resume_game() -> void:
	resume_game()

func _on_pause_menu_retry_level() -> void:
	camera_transition_out()
	transition_into(retry_level)

func retry_level():
	$collageScreen.process_mode = Node.PROCESS_MODE_INHERIT
	$PauseMenu.hide()
	playLevel(currentLevel + 1)

func _on_pause_menu_return_to_menu() -> void:
	transition_into(return_to_menu)

func return_to_menu():
	$PauseMenu.hide()
	$Menu/start.show()
	$Menu/fases.hide()
	$Menu.show()


func camera_transition_in():
	#transição do zoom
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property($Camera2D, "zoom", Vector2(CAMERA_DEFAULT_ZOOM, CAMERA_DEFAULT_ZOOM), 0.5)
	var zoom_inverse = 1 / CAMERA_DEFAULT_ZOOM
	$Camera2D/TransitionScreen.scale = Vector2(zoom_inverse, zoom_inverse)
	# Center transition screen on the camera
	$Camera2D/TransitionScreen.position = -$Camera2D/TransitionScreen.size * zoom_inverse / 2

func camera_transition_out():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property($Camera2D, "zoom", Vector2(CAMERA_ZOOM_OUT, CAMERA_ZOOM_OUT), 0.5)
	var zoom_inverse = 1 / CAMERA_ZOOM_OUT
	$Camera2D/TransitionScreen.scale = Vector2(zoom_inverse, zoom_inverse)
	$Camera2D/TransitionScreen.position = -$Camera2D/TransitionScreen.size * zoom_inverse / 2

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not $Menu.is_visible():
		if $PauseMenu.is_visible():
			resume_game()
		else:
			$PauseMenu.show()
			camera_transition_in()
			$DeathCounter.hide()
			$collageScreen.hide()
			$collageScreen.process_mode = Node.PROCESS_MODE_DISABLED
			if level:
				level.hide()
				level.process_mode = Node.PROCESS_MODE_DISABLED

func resume_game():
	$PauseMenu.hide()
	$DeathCounter.show()
	$collageScreen.show()
	$collageScreen.process_mode = Node.PROCESS_MODE_INHERIT
	if collageMode:
		camera_transition_out()
	if level:
		level.show()
		level.process_mode = Node.PROCESS_MODE_INHERIT
