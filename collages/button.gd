extends StaticBody2D

func _ready():
	$AnimatedSprite2D.animation = "not_pressed"
	$CollisionNotPressed.set_deferred("disabled", false)
	$CollisionPressed.set_deferred("disabled", true)

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("Teste")
	$AnimatedSprite2D.animation = "pressed"
	$CollisionNotPressed.set_deferred("disabled", true)
	$CollisionPressed.set_deferred("disabled", false)
