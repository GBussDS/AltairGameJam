extends Node2D

signal player_death

@export var levelCollages: Array[PackedScene] = []

func _ready() -> void:
	$Player.player_death.connect(_on_player_death)
	$AnimationPlayer.play('movePlataforms')

func start_animations():
	$start/BandeiraSaida.play()
	$end/BandeiraChegada.play()

func _on_player_death():
	player_death.emit()
	reset_player()

func reset_player():
	$Player.global_position = $start/BandeiraSaida.global_position
	$Player.velocity = Vector2.ZERO

func _on_finish_reached(body):
	if body is CharacterBody2D:
		await get_tree().create_timer(1).timeout
		get_parent().nextLevel()
