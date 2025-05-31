extends Node2D

@export var levelCollages: Array[PackedScene] = []

var numDeaths = 0

func _ready():
	$AnimationPlayer.play('movePlataforms')
	
func start_animations():
	$start/BandeiraSaida.play()
	$end/BandeiraChegada.play()

func _on_death(body):
	numDeaths += 1
	$Player.global_position = $start/BandeiraSaida.global_position
	$Label.text = "Mortes: " + str(numDeaths)

func _on_finish_reached(body):
	if body is CharacterBody2D:
		await get_tree().create_timer(1).timeout
		get_parent().nextLevel()
