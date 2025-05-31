extends Node2D

signal player_lost

@export var levelCollages: Array[PackedScene] = []

func _ready() -> void:
	$Player.player_lost.connect(_on_player_lost)

func start_animations():
	$start/BandeiraSaida.play()
	$end/BandeiraChegada.play()

func _on_player_lost():
	emit_signal("player_lost")