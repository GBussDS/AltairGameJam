extends Node2D

const PICKED_UP_SCALE = Vector2(1.5, 1.5)
const TWEEN_DURATION = 0.1

var draggable = false
var dragging = false

var collageMode = true

@export var num = 0

var offset: Vector2
var pickup_tween: Tween
var target_rotation: float = 0.0

@onready var collageScreen = get_parent().get_parent()

func _physics_process(delta):
	rotation_degrees = rotation_degrees + (target_rotation - rotation_degrees) * 0.1
	
	if draggable and not dragging:
		if collageScreen.is_dragging == -1 and Input.is_action_just_pressed("click"):
			collageScreen.is_dragging = num
			# Move para o final da lista para ser desenhado por cima dos outros
			collageScreen.move_child(self, -1)
			z_index = 1
			offset = get_global_mouse_position() - global_position
			dragging = true
			var duration
			if pickup_tween and pickup_tween.is_running():
				duration = pickup_tween.get_total_elapsed_time()
				pickup_tween.kill()
			else:
				duration = TWEEN_DURATION
			pickup_tween = create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
			pickup_tween.tween_property(self, "scale", PICKED_UP_SCALE, duration)
	
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
		pickup_tween.tween_callback(self.set.bind("z_index", 0))
		dragging = false
		collageScreen.is_dragging = -1

func _on_area_2d_mouse_entered():
	if collageMode and collageScreen.is_dragging == -1:
		draggable = true

func _on_area_2d_mouse_exited():
	if collageMode and collageScreen.is_dragging == -1:
		draggable = false
