extends StaticBody2D

var deadly = true

func _ready():
	$AnimatedSprite2D.play()

func _on_area_2d_body_entered(body):
	if deadly:
		deadly = false
		#tinha q passar alguma coisa
		get_parent().get_parent()._on_death('dead')
		await get_tree().create_timer(0.5).timeout
		deadly = true
