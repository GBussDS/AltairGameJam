extends StaticBody2D

@export var strength = 3000.0
@export var scaleX = 1.0
var max_speed = 500.0
var bodies = []

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
