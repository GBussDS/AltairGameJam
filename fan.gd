extends StaticBody2D

@export var strength = 10000

var bodies = []

func _physics_process(delta):
	for body in bodies:
		var direction = Vector2.RIGHT.rotated(global_rotation)
		body.velocity += direction * strength * delta
		body.move_and_slide()
		
func _on_area_2d_body_entered(body):
	if body is CharacterBody2D:
		bodies.append(body)
		body.velocity.y = body.velocity.y/1.5

func _on_area_2d_body_exited(body):
	if body is CharacterBody2D:
		bodies.erase(body)
