extends Node2D

const SHADER = preload("res://shaders/collage.gdshader")
const SHADOW_SHADER = preload("res://shaders/shadow.gdshader")
const PICKUP_SOUNDS = [
	preload("res://sfx/Paper Sound - 1.wav"),
	preload("res://sfx/Paper Sound - 2.wav"),
	preload("res://sfx/Paper Sound - 3.wav")
]

const PICKED_UP_SCALE = Vector2(1.5, 1.5)
const TWEEN_DURATION = 0.1
const SHADER_INTERVAL = 0.5
const IDLE_SHADOW_SCALE = 0.07
const DRAGGING_SHADOW_SCALE = 0.18

var draggable = false
var dragging = false

var collageMode = false

@export var num = 0

var offset: Vector2
var pickup_tween: Tween
var target_rotation: float = 0.0
var shadow_node: Node2D

@onready var collageScreen = get_parent().get_parent()

func _ready() -> void:
	$Sprite2D.material = ShaderMaterial.new()

	shadow_node = $Sprite2D.duplicate()
	shadow_node.name = "Shadow"
	shadow_node.material = ShaderMaterial.new()
	shadow_node.material.shader = SHADOW_SHADER
	var viewport_size = get_viewport_rect().size
	shadow_node.material.set_shader_parameter("screen_center", Vector2(viewport_size.x * 0.5, 0))
	shadow_node.material.set_shader_parameter("shadow_scale", IDLE_SHADOW_SCALE)
	add_child(shadow_node)
	move_child(shadow_node, 1) # Faz a sombra ser desenhada por baixo do sprite principal

	$Sprite2D.material.shader = SHADER
	var random_delay = randf_range(0.0, 2.0)
	$Sprite2D.material.set_shader_parameter("timeDelay", random_delay)
	var random_seed = randi() % 1000
	$Sprite2D.material.set_shader_parameter("seed", random_seed)
	$Sprite2D.material.set_shader_parameter("interval", 9999.0)

func _physics_process(delta):
	rotation_degrees = rotation_degrees + (target_rotation - rotation_degrees) * 0.1

	if draggable and not dragging:
		if Input.is_action_just_pressed("click"):
			# Sobrepõe o dragging
			collageScreen.is_dragging = num
			# Adia a chamada para o final do frame
			# para que a collage que executou por último
			# seja a que será arrastada, pois a última
			# collage a processar é a que é desenhada por cima
			initiate_dragging.call_deferred()
	
	if not dragging:
		return
	
	if Input.is_action_pressed("click") and collageScreen.is_dragging == num:
		if Input.is_action_just_pressed("rodar_horario") or Input.is_action_pressed("rodar_horario"):
			target_rotation += 3
		elif Input.is_action_just_pressed("rodar_anti_horario") or Input.is_action_pressed("rodar_anti_horario"):
			target_rotation -= 3
		elif Input.is_action_just_pressed("rodar_horario_scroll") or Input.is_action_pressed("rodar_horario_scroll"):
			target_rotation += 10
		elif Input.is_action_just_pressed("rodar_anti_horario_scroll") or Input.is_action_pressed("rodar_anti_horario_scroll"):
			target_rotation -= 10
		
		global_position = get_global_mouse_position() - offset
	
	elif Input.is_action_just_released("click") and collageScreen.is_dragging == num:
		var duration
		if pickup_tween and pickup_tween.is_running():
			duration = pickup_tween.get_total_elapsed_time()
			pickup_tween.kill()
		else:
			duration = TWEEN_DURATION
		pickup_tween = create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
		pickup_tween.tween_property(self, "scale", Vector2(1.0, 1.0), duration)
		pickup_tween.tween_callback(self.set.bind("z_index", 1))
		$Sprite2D.material.set_shader_parameter("interval", 9999.0) # Para o shader
		shadow_node.material.set_shader_parameter("shadow_scale", IDLE_SHADOW_SCALE)
		dragging = false
		collageScreen.is_dragging = -1
		play_paper_sound()

func initiate_dragging():
	if collageScreen.is_dragging != num:
		return
	
	# Move para o final da lista para ser desenhado por cima dos outros
	get_parent().move_child(self, -1)
	z_index = 2
	$Sprite2D.material.set_shader_parameter("interval", SHADER_INTERVAL) # Recomeça o shader
	shadow_node.material.set_shader_parameter("shadow_scale", DRAGGING_SHADOW_SCALE)
	offset = get_global_mouse_position() - global_position
	dragging = true
	var duration = TWEEN_DURATION
	if pickup_tween and pickup_tween.is_running():
		duration = pickup_tween.get_total_elapsed_time()
		pickup_tween.kill()
	pickup_tween = create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	pickup_tween.tween_property(self, "scale", PICKED_UP_SCALE, duration)
	play_paper_sound()

func _on_area_2d_mouse_entered():
	if collageMode:
		draggable = true

func _on_area_2d_mouse_exited():
	draggable = false

func play_paper_sound():
	var random_sound = PICKUP_SOUNDS[randi() % PICKUP_SOUNDS.size()]
	$AudioStreamPlayer2D.stream = random_sound
	$AudioStreamPlayer2D.play()
