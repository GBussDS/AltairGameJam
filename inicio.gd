extends Node2D

func _ready():
	hide()

func start_animations():
	print("Teste")
	$BandeiraSaida.play()
	$BandeiraChegada.play()
