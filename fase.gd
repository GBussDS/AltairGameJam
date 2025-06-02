extends Node2D

const SHADOW_SHADER = preload("res://shaders/shadow.gdshader")

signal player_death

@export var is_wide_level: bool = false
@export var levelCollages: Array[PackedScene] = []

func _ready() -> void:
	$Player.player_death.connect(_on_player_death)
	$AnimationPlayer.play('movePlataforms')

	for child in get_children():
		if child is StaticBody2D:
			add_shadow(child)
	
	var saws = get_node("Saws")
	if saws:
		for saw in saws.get_children():
			if saw is Node2D:
				add_shadow(saw)

func add_shadow(node: Node2D) -> void:
	if node.get_node("Shadow"):
		return  # Shadow already exists
	var sprite = node.get_node("Sprite2D")
	if not sprite:
		sprite = node.get_node("AnimatedSprite2D")
	if not sprite:
		return

	var shadow = sprite.duplicate()
	shadow.material = ShaderMaterial.new()
	shadow.material.shader = SHADOW_SHADER
	var viewport_size = get_viewport_rect().size
	var light_source = Vector2(viewport_size.x * 0.5, 0)
	if node.scale.x * sprite.scale.x < 0:
		light_source.y = viewport_size.y
		var diff = light_source - sprite.global_position
		light_source = sprite.global_position + diff.rotated(-2 * sprite.global_rotation)
	shadow.material.set_shader_parameter("screen_center", light_source)
	var shadow_scale = 0.025 / abs(sprite.scale.x)
	shadow.material.set_shader_parameter("shadow_scale", shadow_scale)

	node.add_child(shadow)
	node.move_child(shadow, 0)
	if shadow is AnimatedSprite2D:
		shadow.play()

func start_animations():
	$start/BandeiraSaida.play()
	$end/BandeiraChegada.play()

func _on_player_death():
	player_death.emit()
	reset_player()

func reset_player():
	$Player.global_position = $start/BandeiraSaida.global_position
	$Player.velocity = Vector2.ZERO
	get_tree().create_timer(0.5).timeout.connect(remove_invincibility)

func remove_invincibility():
	$Player.dead = false

func _on_finish_reached(body):
	if body is CharacterBody2D:
		get_parent().nextLevel()
		body.dead = true

func _on_finish_created_level(body):
	if body is CharacterBody2D:
		get_parent().createdLevelEnded()
