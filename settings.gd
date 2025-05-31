extends Control

# Variáveis para armazenar os caminhos dos nós da UI
@onready var volume_geral_slider = $Panel/VBoxContainer/Audio/General/HSlider
@onready var volume_musica_slider = $Panel/VBoxContainer/Audio/Music/HSlider
@onready var volume_efeitos_slider = $Panel/VBoxContainer/Audio/SoundEffects/HSlider

@onready var btn_esquerda_key = $Panel/VBoxContainer/Controls/HBoxContainer/VBoxContainer/Left/Button
@onready var btn_direita_key = $Panel/VBoxContainer/Controls/HBoxContainer/VBoxContainer/Right/Button
@onready var btn_pulo_key = $Panel/VBoxContainer/Controls/HBoxContainer/VBoxContainer/Jump/Button

@onready var btn_rotateleft_key = $Panel/VBoxContainer/Controls/HBoxContainer/VBoxContainer2/RotateLeft/Button
@onready var btn_rotateright_key = $Panel/VBoxContainer/Controls/HBoxContainer/VBoxContainer2/RotateRight/Button

@onready var btn_voltar = $Panel/VBoxContainer/Back

# Caminhos dos Audio Buses
var bus_master_idx = AudioServer.get_bus_index("Master")
var bus_music_idx = AudioServer.get_bus_index("Music")
var bus_sfx_idx = AudioServer.get_bus_index("SFX")

# Variáveis para o mapeamento de teclas
var input_map_data = {
	"left": {"key": KEY_A, "name": "A"},
	"right": {"key": KEY_D, "name": "D"},
	"jump": {"key": KEY_SPACE, "name": "Espaço"},
	"rodar_horario": {"key": KEY_D, "name": "D"},
	"rodar_anti_horario": {"key": KEY_A, "name": "A"}
}

# Variáveis para controle do remapeamento
var is_remapping = false
var current_action_to_remap = ""

# Caminho do arquivo de configurações
const CONFIG_FILE_PATH = "user://game_settings.cfg"
var config = ConfigFile.new()


func _ready():
	# Carrega as configurações ao iniciar
	load_settings()
	hide()

	# Conecta os sinais dos sliders
	volume_geral_slider.value_changed.connect(_on_volume_geral_slider_value_changed)
	volume_musica_slider.value_changed.connect(_on_volume_musica_slider_value_changed)
	volume_efeitos_slider.value_changed.connect(_on_volume_efeitos_slider_value_changed)

	# Conecta os sinais dos botões de remapeamento
	btn_esquerda_key.pressed.connect(func(): start_remapping("left"))
	btn_direita_key.pressed.connect(func(): start_remapping("right"))
	btn_pulo_key.pressed.connect(func(): start_remapping("jump"))
	btn_rotateleft_key.pressed.connect(func(): start_remapping("rodar_anti_horario"))
	btn_rotateright_key.pressed.connect(func(): start_remapping("rodar_horario"))

	# Conecta o botão de voltar
	btn_voltar.pressed.connect(_on_btn_voltar_pressed)

	# Atualiza o texto dos botões de tecla
	update_key_buttons()


func _input(event):
	# Lógica para remapear teclas
	if is_remapping and event is InputEventKey and event.pressed:
		var key_code = event.keycode
		var key_name = OS.get_keycode_string(key_code)

		# Verificações adicionais para evitar remapeamentos indesejados (opcional, pode ser ajustado)
		# Filtra teclas modificadoras comuns que geralmente não são mapeadas como ações sozinhas
		# KEY_META pode ser usado para a tecla Windows/Command/Super em Godot 3.x
		if key_code == KEY_SHIFT or key_code == KEY_CTRL or key_code == KEY_ALT or key_code == KEY_META:
			print("Ignorando tecla modificadora para remapeamento.")
			return # Não remapeia teclas modificadoras sozinhas

		if current_action_to_remap in input_map_data:
			input_map_data[current_action_to_remap]["key"] = key_code
			input_map_data[current_action_to_remap]["name"] = key_name
			
			update_key_buttons()
			remap_action(current_action_to_remap, key_code)
			stop_remapping()
			
			# Consome o evento DEPOIS que o remapeamento é feito
			get_viewport().set_input_as_handled()
			
			# Remove o foco do botão para evitar ativações acidentais
			match current_action_to_remap:
				"left": btn_esquerda_key.release_focus()
				"right": btn_direita_key.release_focus()
				"jump": btn_pulo_key.release_focus()
				"rodar_anti_horario": btn_rotateleft_key.release_focus()
				"rodar_horario": btn_rotateright_key.release_focus()


# Funções de Volume
func _on_volume_geral_slider_value_changed(value):
	AudioServer.set_bus_volume_db(bus_master_idx, linear_to_db(value))
	save_settings()

func _on_volume_musica_slider_value_changed(value):
	AudioServer.set_bus_volume_db(bus_music_idx, linear_to_db(value))
	save_settings()

func _on_volume_efeitos_slider_value_changed(value):
	AudioServer.set_bus_volume_db(bus_sfx_idx, linear_to_db(value))
	save_settings()

# Funções de Mapeamento de Teclas
func start_remapping(action_name):
	is_remapping = true
	current_action_to_remap = action_name
	# Mudar o texto do botão para "Press..."
	match action_name:
		"left": btn_esquerda_key.text = "Press..."
		"right": btn_direita_key.text = "Press..."
		"jump": btn_pulo_key.text = "Press..."
		"rodar_anti_horario": btn_rotateleft_key.text = "Press..."
		"rodar_horario": btn_rotateright_key.text = "Press.."

func stop_remapping():
	is_remapping = false
	current_action_to_remap = ""
	update_key_buttons()
	save_settings()

func update_key_buttons():
	btn_esquerda_key.text = input_map_data["left"]["name"]
	btn_direita_key.text = input_map_data["right"]["name"]
	btn_pulo_key.text = input_map_data["jump"]["name"]
	btn_rotateleft_key.text = input_map_data["rodar_anti_horario"]["name"]
	btn_rotateright_key.text = input_map_data["rodar_horario"]["name"]

func remap_action(action_name, new_key_code):
	# Limpa todos os eventos de input para a ação específica
	InputMap.erase_action(action_name)
	# Adiciona o novo evento de input (tecla)
	InputMap.add_action(action_name)
	var event = InputEventKey.new()
	event.keycode = new_key_code
	InputMap.action_add_event(action_name, event)

# Funções de Salvar/Carregar Configurações
func save_settings():
	config.clear()

	# Salva volumes
	config.set_value("audio", "master_volume", db_to_linear(AudioServer.get_bus_volume_db(bus_master_idx)))
	config.set_value("audio", "music_volume", db_to_linear(AudioServer.get_bus_volume_db(bus_music_idx)))
	config.set_value("audio", "sfx_volume", db_to_linear(AudioServer.get_bus_volume_db(bus_sfx_idx)))

	# Salva mapeamento de teclas
	config.set_value("input", "left_key_code", input_map_data["left"]["key"])
	config.set_value("input", "left_key_name", input_map_data["left"]["name"])
	config.set_value("input", "right_key_code", input_map_data["right"]["key"])
	config.set_value("input", "right_key_name", input_map_data["right"]["name"])
	config.set_value("input", "jump_key_code", input_map_data["jump"]["key"])
	config.set_value("input", "jump_key_name", input_map_data["jump"]["name"])
	config.set_value("input", "rotate_left_key_code", input_map_data["rodar_anti_horario"]["key"])
	config.set_value("input", "rotate_left_key_name", input_map_data["rodar_anti_horario"]["name"])
	config.set_value("input", "rotate_right_key_code", input_map_data["rodar_horario"]["key"])
	config.set_value("input", "rotate_right_key_name", input_map_data["rodar_horario"]["name"])

	var error = config.save(CONFIG_FILE_PATH)
	if error != OK:
		printerr("Erro ao salvar configurações: ", error)
	else:
		print("Configurações salvas com sucesso.")

func load_settings():
	var error = config.load(CONFIG_FILE_PATH)
	if error != OK:
		if error == ERR_FILE_NOT_FOUND:
			print("Arquivo de configurações não encontrado. Usando padrões.")
			# Aplica as configurações padrão ao sistema de áudio e input
			AudioServer.set_bus_volume_db(bus_master_idx, linear_to_db(volume_geral_slider.value))
			AudioServer.set_bus_volume_db(bus_music_idx, linear_to_db(volume_musica_slider.value))
			AudioServer.set_bus_volume_db(bus_sfx_idx, linear_to_db(volume_efeitos_slider.value))
			# Aplica as configurações de input padrão
			remap_action("left", input_map_data["left"]["key"])
			remap_action("right", input_map_data["right"]["key"])
			remap_action("jump", input_map_data["jump"]["key"])
			remap_action("rodar_anti_horario", input_map_data["rodar_anti_horario"]["key"])
			remap_action("rodar_horario", input_map_data["rodar_horario"]["key"])
			save_settings() # Salva as configurações padrão
		else:
			printerr("Erro ao carregar configurações: ", error)
		return

	# Carrega volumes
	var master_vol = config.get_value("audio", "master_volume", 1.0)
	var music_vol = config.get_value("audio", "music_volume", 1.0)
	var sfx_vol = config.get_value("audio", "sfx_volume", 1.0)

	volume_geral_slider.value = master_vol
	volume_musica_slider.value = music_vol
	volume_efeitos_slider.value = sfx_vol

	AudioServer.set_bus_volume_db(bus_master_idx, linear_to_db(master_vol))
	AudioServer.set_bus_volume_db(bus_music_idx, linear_to_db(music_vol))
	AudioServer.set_bus_volume_db(bus_sfx_idx, linear_to_db(sfx_vol))

	# Carrega mapeamento de teclas
	input_map_data["left"]["key"] = config.get_value("input", "left_key_code", KEY_A)
	input_map_data["left"]["name"] = config.get_value("input", "left_key_name", "A")
	input_map_data["right"]["key"] = config.get_value("input", "right_key_code", KEY_D)
	input_map_data["right"]["name"] = config.get_value("input", "right_key_name", "D")
	input_map_data["jump"]["key"] = config.get_value("input", "jump_key_code", KEY_SPACE)
	input_map_data["jump"]["name"] = config.get_value("input", "jump_key_name", "Espaço")

	remap_action("left", input_map_data["left"]["key"])
	remap_action("right", input_map_data["right"]["key"])
	remap_action("jump", input_map_data["jump"]["key"])
	remap_action("rodar_anti_horario", input_map_data["rodar_anti_horario"]["key"])
	remap_action("rodar_horario", input_map_data["rodar_horario"]["key"])

	update_key_buttons()
	print("Configurações carregadas com sucesso.")

# Função de Voltar
func _on_btn_voltar_pressed():
	save_settings() # Garante que as configurações foram salvas ao sair
	hide()
	get_parent().show_menu()
