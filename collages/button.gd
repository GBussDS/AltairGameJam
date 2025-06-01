extends StaticBody2D

@export var pressed = false
@export var timer = 1

func _ready():
	$AnimatedSprite2D.animation = "not_pressed"
	$CollisionNotPressed.set_deferred("disabled", false)
	$CollisionPressed.set_deferred("disabled", true)

func _on_area_2d_body_entered(body: Node2D) -> void:
	$AnimatedSprite2D.animation = "pressed"
	$CollisionNotPressed.set_deferred("disabled", true)
	$CollisionPressed.set_deferred("disabled", false)
	pressed = true
	await get_tree().create_timer(timer).timeout
	pressed = false
	$AnimatedSprite2D.animation = "not_pressed"
	$CollisionNotPressed.set_deferred("disabled", false)
	$CollisionPressed.set_deferred("disabled", true)
