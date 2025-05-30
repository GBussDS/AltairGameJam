extends Node2D

func _ready():
	hide()

func start_animations():
	$BandeiraSaida.play()
	$BandeiraChegada.play()
