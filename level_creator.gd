extends Node2D

@export var collages: Array[PackedScene] = []

var sum = 1

var makerCollages = []
var playerCollages = []

var wide = true

@export var flags_texture: Texture2D = preload("res://art/flags.png")

func _input(event):
	if event.is_action_pressed('jump'):
		sum *= -1
		
		if sum == -1:
			$toMaker/title/Label.text = 'para a fase: -'
			$toPlayer/title/Label.text = 'para a fase: -'
		else:
			$toMaker/title/Label.text = 'para a fase: +'
			$toPlayer/title/Label.text = 'para a fase: +'
			
func _ready():
	for button in $toMaker/collages.get_children():
		if button is Button:
			button.button_up.connect(_on_collage_button_up.bind(button))
	
	for button in $toPlayer/collages.get_children():
		if button is Button:
			button.button_up.connect(_on_collage_button_up.bind(button))
	
func _on_collage_button_up(button: BaseButton):
	var newNum = int(button.text) + sum
	
	if newNum < 0:
		newNum = 0
	elif newNum > 50:
		newNum = 50
		
	button.text = str(newNum)

func _on_confirm_button_up():
	for child in $toMaker/collages.get_children():
		for i in range(int(child.text)):
			makerCollages.append(collages[int(child.name)])
	
	var image = flags_texture.get_image()
	
	var tile_size = Vector2i(16, 16)
	var gridStart = Vector2i(0, 2)
	var gridEnd = Vector2i(0, 1)

	var regionStart = image.get_region(
		Rect2i(
			gridStart.x * tile_size.x,
			gridStart.y * tile_size.y,
			tile_size.x,
			tile_size.y
		)
	)
	var regionEnd = image.get_region(
		Rect2i(
			gridEnd.x * tile_size.x,
			gridEnd.y * tile_size.y,
			tile_size.x,
			tile_size.y
		)
	)
	
	var start = Sprite2D.new()
	start.texture = ImageTexture.create_from_image(regionStart)
	
	var end = Sprite2D.new()
	end.texture = ImageTexture.create_from_image(regionEnd)
	
	start.name = 'start'
	end.name = 'end'
	
	start.scale = Vector2(5.0, 5.0)
	end.scale = Vector2(5.0, 5.0)
	
	makerCollages.append(start)
	makerCollages.append(end)
	
	$toMaker.hide()
	$toPlayer.show()

func _on_confirm_player():
	for child in $toPlayer/collages.get_children():
		for i in range(int(child.text)):
			playerCollages.append(collages[int(child.name)])
			
	$toPlayer.hide()
	$sizeSelect.show()
	
func _on_tamanho(body, size):
	if size == 'normal':
		wide = false
	else:
		wide == true

func _on_size_toggled(toggled_on, big):
	if big and toggled_on:
		wide = true
		$sizeSelect/normal/CheckButton2.button_pressed = false
	elif big and not toggled_on:
		wide = false
		$sizeSelect/normal/CheckButton2.button_pressed = true
	elif not big and toggled_on:
		wide = false
		$sizeSelect/grande/CheckButton.button_pressed = false
	elif not big and not toggled_on:
		wide = true
		$sizeSelect/grande/CheckButton.button_pressed = true

func _on_size_choosen():
	$sizeSelect.hide()
	get_parent().create_level(makerCollages, playerCollages, wide)
	
