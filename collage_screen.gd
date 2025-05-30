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
		collage.position = spawn_point.position
		collage.collageMode = true
		
		$collagesGroup.add_child(collage)

func _on_area_collages_exited(body):
	collageCount -= 1
	
	if collageCount < 0:
		collageCount = 0
		
func _on_confirm_pressed():
	is_dragging = -2
	get_parent().collageEnded()
