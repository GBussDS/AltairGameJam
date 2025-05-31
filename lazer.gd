extends StaticBody2D

@export var max_distance: float = 1000.0
@export var laser_width: float = 2.0
@export var color: Color = Color.RED

@onready var ray_cast: RayCast2D = $RayCast2D
@onready var line: Line2D = $Line2D

@onready var fimLazer = $fimLazer

var deadly = true

var toggle_button: StaticBody2D = null
var toggle_laser_enabled = true

func _ready():
	line.width = laser_width
	line.points[1].x = max_distance
	line.default_color = color
	ray_cast.target_position = Vector2(max_distance, 0)
	fimLazer.position = Vector2(max_distance, 0)
	# Encontra os botões e conecta os sinais
	find_and_connect_buttons()

func _process(delta):
	if not toggle_button:
		update_laser()
	else:
		if not toggle_button.pressed:
			update_laser()
		else:
			line.points = []
			fimLazer.hide()
			ray_cast.enabled = false
			deadly = false

func update_laser():
	ray_cast.enabled = true
	deadly = true
	fimLazer.show()
	if ray_cast.is_colliding():
		var collider = ray_cast.get_collider()
		if deadly and collider is CharacterBody2D:
			collider.die()
		var collision_point = ray_cast.get_collision_point()
		fimLazer.global_position = collision_point
		line.points = [Vector2.ZERO, to_local(collision_point)]
	else:
		fimLazer.position = Vector2(max_distance, 0)
		line.points = [Vector2.ZERO, Vector2(max_distance, 0)]

func find_and_connect_buttons():
	if not get_parent():
		printerr("Laser não tem pai para encontrar botões.")
		return

	for child in get_parent().get_children():
		# Verifica se o filho é um botão e, opcionalmente, se tem um nome específico
		if child.name == "Button":
			toggle_button = child
			break
