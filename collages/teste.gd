extends Node2D

func _process(delta: float) -> void:
	if $Collage.pressed == true:
		$lazer/Line2D.hide()
	else:
		$lazer/Line2D.show()
