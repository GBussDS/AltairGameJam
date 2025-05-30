extends Node2D

@onready var spawn_point = $SpawnArea/collageSpawn

@export var is_dragging = -1

var collageCount = 0

func _process(delta):
	if collageCount == 0:
		$confirm.disabled = false
		
func _ready():
	for i in range(3):
		collageCount += 1
		spawn_point.progress_ratio = randf()
		
		var collage = load('res://collage.tscn').instantiate()
		collage.num = i
		collage.global_position = spawn_point.global_position
		
		$collagesGroup.add_child(collage)

func _on_area_collages_exited(body):
	collageCount -= 1
	
	if collageCount < 0:
		collageCount = 0
		
func _on_confirm_pressed():
	get_parent().collageEnded()
