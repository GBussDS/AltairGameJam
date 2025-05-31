extends StaticBody2D

func _ready():
	$AnimatedSprite2D.play()

func _on_area_2d_body_entered(body):
	if body is CharacterBody2D:
		body.die()
