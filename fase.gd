extends Node2D

@export var levelCollages: Array[PackedScene] = []

func start_animations():
	$start/BandeiraSaida.play()
	$end/BandeiraChegada.play()
