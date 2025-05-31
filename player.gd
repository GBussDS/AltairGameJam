extends CharacterBody2D

const SHADOW_SHADER = preload("res://shaders/shadow.gdshader")

@export var speed = 300.0  # Velocidade de movimento horizontal
@export var jump_velocity = -700.0 # Força do pulo

# Gravidade para o CharacterBody2D
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jumping = false # Variável para controlar se o player está pulando
var was_on_floor = false # Variável para rastrear o estado do chão no frame anterior

# --- Variáveis para pulo variável (jump cut) ---
var jump_cut_multiplier := 0.5    # Quanto multiplicar a velocidade do pulo se soltar o botão cedo
var max_jump_time := 0.25         # Tempo max. que o player pode segurar o botão de pulo para pular mais alto
var jump_time := 0.0              # Contador de tempo de pulo atual

# --- Variáveis para coyote time (pular fora do bloco) ---
var coyote_time_max := 0.3        # Duração máxima do coyote time
var time_since_left_ground := 0.0 # Contador de quanto tempo se passou desde que saiu do chão

func _ready():
	$AnimatedSprite2D.play()
	var viewport_size = get_viewport_rect().size
	$Shadow.material.set_shader_parameter("screen_center", Vector2(viewport_size.x * 0.5, 0))
	$Shadow.play()

	was_on_floor = is_on_floor() # Inicializa o estado do chão

func _physics_process(delta):
	# ===== Gerenciamento de coyote time =====
	if is_on_floor():
		time_since_left_ground = 0.0
	else:
		time_since_left_ground += delta

	# Lógica de Gravidade e Movimento
	if not is_on_floor():
		velocity.y += gravity * delta

		# Enquanto estiver no “pulo inicial” (jumping). Se pressionar por mais tempo, pula mais
		if jumping:
			jump_time += delta
			if jump_time >= max_jump_time:
				jumping = false  # Depois de x segundos, encerra o modo “sustentar pulo”
	else:
		jump_time = 0.0
		jumping = false

	# Corte de pulo se soltar a tecla cedo
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= jump_cut_multiplier
		jumping = false

	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * speed
		$AnimatedSprite2D.flip_h = velocity.x < 0
		$Shadow.flip_h = velocity.x < 0
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	# Lógica de Pulo com coyote time
	# Agora permitimos pular se está no chão OU se saiu do chão há menos de coyote_time_max
	if Input.is_action_just_pressed("jump") and (is_on_floor() or time_since_left_ground < coyote_time_max):
		velocity.y = jump_velocity
		jumping = true # Define que o player está pulando
		jump_time = 0.0
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
