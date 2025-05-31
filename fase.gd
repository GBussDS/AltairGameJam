extends Node2D

signal player_death

@export var levelCollages: Array[PackedScene] = []

var numDeaths = 0

func _ready() -> void:
	$Player.player_death.connect(_on_player_death)

func start_animations():
	$start/BandeiraSaida.play()
	$end/BandeiraChegada.play()

func _on_player_death():
	numDeaths += 1
	player_death.emit()
	reset_player()

func reset_player():
	$Player.global_position = $start/BandeiraSaida.global_position
	$Player.velocity = Vector2.ZERO