extends Node2D

var draggable = false
var dragging = false

@export var num = 0

var offset: Vector2

func _physics_process(delta):
	if draggable:
		if get_parent().is_dragging == -1 and Input.is_action_just_pressed("click"):
			get_parent().is_dragging = num
			offset = get_global_mouse_position() - global_position
		
		if Input.is_action_pressed("click") and get_parent().is_dragging == num:
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
		
		if Input.is_action_just_released("click") and get_parent().is_dragging == num:
			get_parent().is_dragging = -1

func _on_area_2d_mouse_entered():
	if get_parent().is_dragging == -1:
		draggable = true

func _on_area_2d_mouse_exited():
	if get_parent().is_dragging == -1:
		draggable = false
