extends Node2D

@onready var spawn_point = $SpawnArea/collageSpawn

@export var is_dragging = -1

@onready var parent = get_parent()

var collageCount = 0

func _process(delta):
	if collageCount == 0:
		$confirm.disabled = false

func _on_area_collages_exited(body):
	collageCount -= 1
	
	if collageCount < 0:
		collageCount = 0
		
func _on_confirm_pressed():
	is_dragging = -2
	get_parent().collageEnded()
	$confirm.disabled = true

func createCollages():
	for child in $collagesGroup.get_children():
		child.queue_free()
	collageCount = 0
	is_dragging = -1
	$confirm.disabled = false
	for collagePath in parent.currentCollages:
		collageCount += 1
		spawn_point.progress_ratio = randf()
		
		var collage = collagePath.instantiate()
		collage.num = collageCount
		collage.position = spawn_point.position
		collage.collageMode = true
		
		$collagesGroup.add_child(collage)
