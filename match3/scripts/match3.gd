extends Control

export var width : int = 10
export var height : int = 8
export var selected_material : Material

signal moved_gem
signal scored(score)

var rng = RandomNumberGenerator.new()

var empty_gem : TextureRect = null
var gems = []
var gem_field = []
var selected_gem : Control = null
var can_select = true

var is_dragging = false # Godot bug: https://github.com/godotengine/godot/issues/20881


func is_selected_gem() -> bool:
	return selected_gem != null


func mouse_pressed_gem(gem):
	if not can_select:
		_unselect_gem()
		return
		
	if is_selected_gem():
		_try_gem_switch(gem.field_pos, selected_gem.field_pos)
	else:
		_select_gem(gem)


func mouse_released_gem(gem):
	pass


func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			_unselect_gem()
				

func _ready():
	rng.randomize() # use time as seed.
	
	# Collect gem instances
	for child in get_children():
		if child.has_method("init_gem"):
			gems.append(child)
			child.visible = false
			
			if empty_gem == null:
				empty_gem = child.duplicate()
				empty_gem.visible = false
				empty_gem.modulate.a = 0


func _process(delta):
	if not $Field.disable_sort:
		$Field.disable_sort = true


func _select_gem(gem):
	if not can_select:
		return
	print("Selected {0},{1}".format([gem.field_pos.x, gem.field_pos.y]))
	selected_gem = gem
	selected_gem.material = selected_material
	

func _unselect_gem():
	if selected_gem == null:
		return
	print("Unselected")
	selected_gem.material = null
	selected_gem = null
	

func _try_gem_switch(gem_pos_a, gem_pos_b):
	var dx : int = abs(gem_pos_a.x - gem_pos_b.x)
	var dy : int = abs(gem_pos_a.y - gem_pos_b.y)
	
	if dx == 1 and dy == 0:
		_gem_switch(gem_pos_a, gem_pos_b)
	elif dx == 0 and dy == 1:
		_gem_switch(gem_pos_a, gem_pos_b)
	else:
		_unselect_gem()


func _gem_switch(gem_pos_a, gem_pos_b):
	can_select = false
	emit_signal("moved_gem")
	
	var delay = 0.5
	var idx_a = gem_pos_a.y*width + gem_pos_a.x
	var idx_b = gem_pos_b.y*width + gem_pos_b.x
	
	var temp = gem_field[idx_a]
	gem_field[idx_a] = gem_field[idx_b]
	gem_field[idx_b] = temp
	
	_unselect_gem()
	_display_field()
	
	yield(get_tree().create_timer(delay), "timeout")
	
	var combo : int = 0
	var total_score : int = 0
	
	var score = _match_gems([gem_pos_a, gem_pos_b])
	_display_field()
	
	while score:
		combo += 1
		var rate = pow(combo, 0.35)
		total_score += score * rate
		
		yield(get_tree().create_timer(delay), "timeout")

		var pos_list = _refill_gems()
		_display_field()

		yield(get_tree().create_timer(delay), "timeout")

		score = _match_gems(pos_list)
		_display_field()

	emit_signal("scored", total_score)
	can_select = true


func generate_field():
	var dup_x = 0
	
	print("generate_field")
	gem_field.clear()
	for i in range(height*width):
		var gem_list = range(gems.size())
		var gem_id = rng.randi_range(0, gems.size()-1)
		gem_list.remove(gem_id)
		
		# Don't generate a match-3 on X axis.
		if i%width != 0 and gem_field[i-1] == gem_id:
			dup_x += 1
		else:
			dup_x = 0
			
		if dup_x >= 2:
			gem_id = gem_list[rng.randi_range(0, gem_list.size()-1)]
			gem_list.remove(gem_list.find(gem_id))
			dup_x = 0
			
		# Don't generate a match-3 on Y axis.
		if i >= width*2 and gem_field[i-width] == gem_id and gem_field[i-width*2] == gem_id:
			gem_id = gem_list[rng.randi_range(0, gem_list.size()-1)]
			
		gem_field.append(gem_id)

	_display_field()


func _display_field():
	$Field.disable_sort = false
	
	$Field.columns = width
	
	for c in $Field.get_children():
		$Field.remove_child(c)
		c.queue_free()
	
	for j in range(height):
		for i in range(width):
			var gem_id = _get_gem_id(i, j)
			
			var gem = empty_gem
			if gem_id >= 0:
				gem = gems[gem_id]
				
			gem = gem.duplicate()
			gem.visible = true
			$Field.add_child(gem)
			gem.init_gem(self, i, j)


func _match_gems(positions) -> int:
	var score = 0
	
	for pos in positions:
		var match_count = _match_gem(pos)
		if match_count > 0:
			score += (pow(match_count, 1.2) - 2.5) * 100
	
	return score


func _find_x_length(x, y):
	var dx = {"left": 0, "right": 0}
	var ori_gem_id = _get_gem_id(x, y);
	
	if ori_gem_id < 0:
		return dx
	
	for i in range(1, height):
		var gem_id = _get_gem_id(x-i, y)
		if gem_id == ori_gem_id:
			dx.left += 1
		else:
			break
	
	for i in range(1, height):
		var gem_id = _get_gem_id(x+i, y)
		if gem_id == ori_gem_id:
			dx.right += 1
		else:
			break
			
	return dx


func _find_y_length(x, y):
	var dy = {"down": 0, "up": 0}
	var ori_gem_id = _get_gem_id(x, y);
	
	if ori_gem_id < 0:
		return dy
	
	for i in range(1, height):
		var gem_id = _get_gem_id(x, y+i)
		if gem_id == ori_gem_id:
			dy.up += 1
		else:
			break
	
	for i in range(1, height):
		var gem_id = _get_gem_id(x, y-i)
		if gem_id == ori_gem_id:
			dy.down += 1
		else:
			break
			
	return dy


func _match_gem(pos) -> int:
	var dx = _find_x_length(pos.x, pos.y)
	var dy = _find_y_length(pos.x, pos.y)

	var h = dx.left + dx.right + 1
	var v = dy.down + dy.up + 1
	
	if h < 3:
		dx.left = 0
		dx.right = 0
		h = 0
	if v < 3:
		dy.down = 0
		dy.up = 0
		v = 0
	
	if h >= 3 or v >= 3:
		gem_field[pos.y*width + pos.x] = -1
		
		for i in range(1, dx.left+1):
			gem_field[pos.y*width + pos.x - i] = -1
		for i in range(1, dx.right+1):
			gem_field[pos.y*width + pos.x + i] = -1
			
		for i in range(1, dy.down+1):
			gem_field[(pos.y - i)*width + pos.x] = -1
		for i in range(1, dy.up+1):
			gem_field[(pos.y + i)*width + pos.x] = -1

	return h+v


func _get_gem_id(x, y):
	if x < 0 or x >= width or y < 0 or y >= height:
		return -1
	return gem_field[y*width + x]


func _drop_gems(x, y):
	var pos_list = []
	
	for j in range(y, -1, -1):
		var idx = j*width + x
		var prev_idx = (j-1)*width + x
		
		if prev_idx < 0 or gem_field[prev_idx] < 0:
			gem_field[idx] = rng.randi_range(0, gems.size()-1)
		else:
			gem_field[idx] = gem_field[prev_idx]
			
		pos_list.append({"x": x, "y": j})

	return pos_list


func _refill_gems():
	var pos_list = []
	for j in range(height-1, 0-1, -1):
		for i in range(width):
			var id = _get_gem_id(i, j)
			if id < 0:
				var list = _drop_gems(i, j)
				pos_list += list

	return pos_list
