extends StaticBody2D

const COLLAGE_SHADER = preload("res://shaders/collage.gdshader")
const SHADOW_SHADER = preload("res://shaders/shadow.gdshader")

const WIND_STRIP_SHIFT_TIME = 1
const WIND_STRIP_SHIFT_DISTANCE = 50.0

@export var strength = 3000.0
@export var scaleX = 1.0
var max_speed = 500.0
var bodies = []
var windStripShiftTimer: float = 0.0

func _ready() -> void:
	for child in $WindStrips.get_children():
		var strip = child.find_child("Strip")
		var shadow = strip.duplicate()
		strip.material = ShaderMaterial.new()

		strip.material.shader = COLLAGE_SHADER
		strip.material.set_shader_parameter("intensityX", 2.0)
		strip.material.set_shader_parameter("intensityY", 2.0)
		strip.material.set_shader_parameter("interval", 0.4)
		var random_delay = randf_range(0.0, 2.0)
		strip.material.set_shader_parameter("timeDelay", random_delay)
		var random_seed = randi() % 1000
		strip.material.set_shader_parameter("seed", random_seed)

		shadow.name = strip.name + "Shadow"
		shadow.material = ShaderMaterial.new()
		shadow.material.shader = SHADOW_SHADER
		shadow.material.set_shader_parameter("screen_center", Vector2(get_viewport_rect().size.x * 0.5, 0))
		# shadow.material.set_shader_parameter("shadow_scale", 0.07)
		child.add_child(shadow)
		child.move_child(shadow, 0)  # Move shadow to be drawn below the main sprite

func _process(delta: float) -> void:
	windStripShiftTimer += delta
	if windStripShiftTimer >= WIND_STRIP_SHIFT_TIME:
		windStripShiftTimer = 0.0
		for child in $WindStrips.get_children():
			var random_x_shift = randf_range(-WIND_STRIP_SHIFT_DISTANCE, WIND_STRIP_SHIFT_DISTANCE)
			var random_y_shift = randf_range(-WIND_STRIP_SHIFT_DISTANCE, WIND_STRIP_SHIFT_DISTANCE)
			child.position = Vector2(random_x_shift, random_y_shift)

func _physics_process(delta):
	scale.x = scaleX
	
	for body in bodies:
		var direction = Vector2.RIGHT.rotated(global_rotation).normalized()
		body.velocity = body.velocity + direction * strength * delta
		
		if body.velocity.length() > max_speed:
			body.velocity = body.velocity.normalized() * max_speed
			
		body.move_and_slide()
		
func _on_area_2d_body_entered(body):
	if body is CharacterBody2D and not bodies.has(body):
		bodies.append(body)
		

func _on_area_2d_body_exited(body):
	if body is CharacterBody2D:
		bodies.erase(body)
