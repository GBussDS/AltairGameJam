extends CharacterBody2D

const SHADOW_SHADER = preload("res://shaders/shadow.gdshader")

@export var speed = 300.0  # Velocidade de movimento horizontal
@export var jump_velocity = -700.0 # Força do pulo

# Gravidade para o CharacterBody2D
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jumping = false # Variável para controlar se o player está pulando
var was_on_floor = false # Variável para rastrear o estado do chão no frame anterior

func _ready():
	$AnimatedSprite2D.play()
	var viewport_size = get_viewport_rect().size
	$Shadow.material.set_shader_parameter("screen_center", Vector2(viewport_size.x * 0.5, viewport_size.y * 0.5))
	$Shadow.play()

	was_on_floor = is_on_floor() # Inicializa o estado do chão

func _physics_process(delta):
	# Lógica de Gravidade e Movimento
	if not is_on_floor():
		velocity.y += gravity * delta

	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * speed
		$AnimatedSprite2D.flip_h = velocity.x < 0
		$Shadow.flip_h = velocity.x < 0
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	# Lógica de Pulo
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		jumping = true # Define que o player está pulando
		set_animation("jump")

	# Lógica de Animação

	# Animação de Pulo
	if jumping:
		set_animation("jump")

	# Animação de Pouso (Land)
	if is_on_floor() and not was_on_floor: # Se estava no ar e agora está no chão
		if jumping: # Apenas se ele estava realmente em um estado de pulo antes
			set_animation("land")
			jumping = false


	# Animações de Andar/Parar (apenas se não estiver pulando e estiver no chão)
	if is_on_floor() and not jumping: # Certifica-se de que não está pulando
		if direction:
			set_animation("walk")
		else:
			set_animation("stop")

	# === Atualiza o estado do chão para o próximo frame ===
	was_on_floor = is_on_floor()

	# === Mover o player ===
	move_and_slide()

func set_animation(animation_name: String) -> void:
	# Método para definir a animação do AnimatedSprite2D e do Shadow
	if $AnimatedSprite2D.animation != animation_name:
		$AnimatedSprite2D.animation = animation_name
		$Shadow.animation = animation_name
