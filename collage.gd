extends Node2D

var draggable = false
var dragging = true

var offset: Vector2

func _physics_process(delta):
	if draggable:
		if Input.is_action_just_pressed("click"):
			print(draggable)
			z_index = 1
			offset = get_global_mouse_position() - global_position
			dragging = true
		
		if Input.is_action_pressed("click"):
			print('draggable1')
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
			draggable = false

func _on_area_2d_mouse_entered():
	draggable = true
