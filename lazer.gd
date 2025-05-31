extends StaticBody2D

@export var max_distance: float = 1000.0
@export var laser_width: float = 2.0
@export var color: Color = Color.RED

@onready var ray_cast: RayCast2D = $RayCast2D
@onready var line: Line2D = $Line2D

@onready var fimLazer = $fimLazer

var deadly = true

func _ready():
	line.width = laser_width
	line.points[1].x = max_distance
	line.default_color = color
	ray_cast.target_position = Vector2(max_distance, 0)
	fimLazer.position = Vector2(max_distance, 0)

func _process(delta):
	update_laser()

func update_laser():
	if ray_cast.is_colliding():
		var collider = ray_cast.get_collider()
		if collider.name is CharacterBody2D:
			collider.die()
			return
		var collision_point = ray_cast.get_collision_point()
		fimLazer.global_position = collision_point
		line.points = [Vector2.ZERO, to_local(collision_point)]
	else:
		fimLazer.position = Vector2(max_distance, 0)
		line.points = [Vector2.ZERO, Vector2(max_distance, 0)]
