extends Node2D

@export var levelCollages: Array[PackedScene] = []

var numDeaths = 0

func start_animations():
	$start/BandeiraSaida.play()
	$end/BandeiraChegada.play()

func _on_death(body):
	numDeaths += 1
	$Player.global_position = $start/BandeiraSaida.global_position
	$Label.text = "Mortes: " + str(numDeaths)
