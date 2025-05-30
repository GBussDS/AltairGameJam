extends Node2D

const PICKED_UP_SCALE = Vector2(1.5, 1.5)
const TWEEN_DURATION = 0.1

var draggable = false
var dragging = false

var offset: Vector2
var pickup_tween: Tween

func _physics_process(delta):
	if draggable and not dragging:
		if Input.is_action_just_pressed("click"):
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
	
	if Input.is_action_pressed("click"):
		if Input.is_action_just_pressed("rodar_horario") or Input.is_action_pressed("rodar_horario"):
			rotation_degrees += 3
		elif Input.is_action_just_pressed("rodar_anti_horario") or Input.is_action_pressed("rodar_anti_horario"):
			rotation_degrees -= 3
		elif Input.is_action_just_pressed("rodar_horario_scroll") or Input.is_action_pressed("rodar_horario_scroll"):
			rotation_degrees += 10
		elif Input.is_action_just_pressed("rodar_anti_horario_scroll") or Input.is_action_pressed("rodar_anti_horario_scroll"):
			rotation_degrees -= 10
			
		rotation_degrees = int(wrapf(rotation_degrees, 0, 360))
		
		global_position = get_global_mouse_position() - offset
	
	elif Input.is_action_just_released("click"):
		z_index = 0
		var duration
		if pickup_tween and pickup_tween.is_running():
			duration = pickup_tween.get_total_elapsed_time()
			pickup_tween.kill()
		else:
			duration = TWEEN_DURATION
		pickup_tween = create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
		pickup_tween.tween_property(self, "scale", Vector2(1.0, 1.0), duration)
		dragging = false

func _on_area_2d_mouse_entered():
	draggable = true

func _on_area_2d_mouse_exited():
	draggable = false
