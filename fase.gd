extends Node2D

@export var levelCollages = ["res://collages/handler.tscn", "res://collages/car.tscn","res://collages/pot.tscn"]

func start_animations():
	$start/BandeiraSaida.play()
	$end/BandeiraChegada.play()
