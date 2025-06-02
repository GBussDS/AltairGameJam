extends Node2D

@export var collages: Array[PackedScene] = []

var sum = 1

var makerCollages = []
var playerCollages = []

var wide = true

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
	
	var image = Image.load_from_file("res://art/flags.png")
	
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
	
func save_scene_list(data: Array) -> String:
	var serialized := [
		_nodes_to_dicts(data[0]),
		_nodes_to_dicts(data[1]),
		data[2]
	]
	
	var json_str := JSON.stringify(serialized)
	var compressed := json_str.to_utf8_buffer().compress(FileAccess.COMPRESSION_GZIP)
	return Marshalls.raw_to_base64(compressed)

func _nodes_to_dicts(nodes: Array):
	var result := []
	for node in nodes:
		if node is Node:
			var entry := {
				"path": node.scene_file_path,
				"name": node.name,
				"position": node.position,
				"rotation": node.rotation,
				"children": _save_children_recursive(node)  # Saves ALL children
			}
			result.append(entry)
	return result

func _save_children_recursive(parent: Node) -> Array:
	var children_data := []
	for child in parent.get_children():
		if child.owner == parent:  
			continue
			
		children_data.append({
			"path": child.scene_file_path if child.scene_file_path else "",
			"name": child.name,
			"position": child.position.x,
			"rotation": child.rotation.x,
			"children": _save_children_recursive(child)
		})
	return children_data

func load_scene_list(encoded_str: String, parent_node: Node) -> Array:
	var compressed := Marshalls.base64_to_raw(encoded_str)
	var json_str := compressed.decompress(FileAccess.COMPRESSION_GZIP).get_string_from_utf8()
	var parsed: Array = JSON.parse_string(json_str)
	
	return [
		_dicts_to_nodes(parsed[0], parent_node),
		_dicts_to_nodes(parsed[1], parent_node),
		parsed[2]
	]

func _dicts_to_nodes(data: Array[Dictionary], parent: Node) -> Array[Node]:
	var nodes := []
	for entry in data:
		if entry.has("path"):
			var instance: Node
			
			if entry["path"] and ResourceLoader.exists(entry["path"]):
				instance = load(entry["path"]).instantiate()
			else:
				instance = Node.new()
			
			instance.name = entry["name"]
			instance.position = Vector3(entry["position"][0], entry["position"][1], entry["position"][2])
			instance.rotation = Vector3(entry["rotation"][0], entry["rotation"][1], entry["rotation"][2])
			
			parent.add_child(instance)
			
			if entry.has("children"):
				_load_children_recursive(entry["children"], instance)
			
			nodes.append(instance)
	return nodes

func _load_children_recursive(children_data: Array, new_parent: Node):
	for child_data in children_data:
		var child: Node
		if child_data["path"] and ResourceLoader.exists(child_data["path"]):
			child = load(child_data["path"]).instantiate()
		else:
			child = Node.new()
		
		child.name = child_data["name"]
		child.position = Vector3(child_data["position"][0], child_data["position"][1], child_data["position"][2])
		child.rotation = Vector3(child_data["rotation"][0], child_data["rotation"][1], child_data["rotation"][2])
		
		new_parent.add_child(child)
		
		if child_data.has("children"):
			_load_children_recursive(child_data["children"], child)

func _is_valid_input(data: String) -> bool:
	return data.length() > 10 or (data.begins_with("[") and data.ends_with("]"))
	
func _on_codigo():
	var encoded_data = $codigo/edit/TextEdit.text.strip_edges()
	
	if encoded_data.is_empty():
		$codigo.hide()
		$toMaker.show()
		return
	
	if not _is_valid_input(encoded_data):
		$codigo/edit/TextEdit.text = "Invalid Code!"
		await get_tree().create_timer(1.0).timeout
		$codigo/edit/TextEdit.text = ''
		return
		
	var loaded_list
	var success = false

	loaded_list = load_scene_list(encoded_data, get_parent())
	success = loaded_list.size() == 3 and loaded_list[2] is bool
	
	if success:
		get_parent().create_level(loaded_list[0], loaded_list[1], loaded_list[2])
		$codigo.hide()
	else:
		# Show error feedback before hiding
		$codigo/edit/TextEdit.text = "Invalid Code!"
		await get_tree().create_timer(1.0).timeout
		$codigo/edit/TextEdit.text = ''

func _on_retry():
	get_parent().level.emit('player_death')
	$retry.hide()
