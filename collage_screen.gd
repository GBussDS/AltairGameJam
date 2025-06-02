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

func createCollages():
	for collagePath in parent.currentCollages:
		collageCount += 1
		spawn_point.progress_ratio = randf()
		
		var collage
		
		if collagePath is PackedScene:
			collage = collagePath.instantiate()
		else:
			collage = collagePath
			
		if collage.name == 'Collage':
			collage.num = collageCount
			collage.position = spawn_point.position
			collage.collageMode = true
			
			$collagesGroup.add_child(collage)
		else:
			var collageContainer = load('res://collage.tscn').instantiate()
			
			collageContainer.get_node('Sprite2D').hide()
			collageContainer.get_node('CollisionShape2D').free()
			
			collageContainer.num = collageCount
			collageContainer.position = spawn_point.position
			collageContainer.collageMode = true
			
			collageContainer.add_child(collage)
			
			if collage.name == 'start':
				collageContainer.name = 'start'
			elif collage.name == 'end':
				collageContainer.name = 'end'
				
			$collagesGroup.add_child(collageContainer)
