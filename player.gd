extends CharacterBody2D

@export var speed = 300.0  # Velocidade de movimento horizontal
@export var jump_velocity = -700.0 # Força do pulo

# Gravidade para o CharacterBody2D
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# Aplicar gravidade se não estiver no chão
	if not is_on_floor():
		velocity.y += gravity * delta

	# Processar input horizontal (A e D)
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed) # Desacelera quando não há input

	# Processar input de pulo (Espaço)
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Mover o player
	move_and_slide()
