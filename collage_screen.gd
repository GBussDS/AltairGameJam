extends Node2D

@onready var spawn_point = $SpawnArea/collageSpawn

@export var is_dragging = -1

func _ready():
	for i in range(3):
		spawn_point.progress_ratio = randf()
		
		var collage = load('res://collage.tscn').instantiate()
		collage.num = i
		collage.global_position = spawn_point.global_position
		
		add_child(collage)
		
