extends Control

export var width : int = 10
export var height : int = 8


var gems = []
var gem_field = []


func _ready():
	# Collect gem instances
	for child in get_children():
		if child.editor_description.begins_with("gem"):
			gems.append(child)
			child.visible = false
			
	_generate_field()
	_display_field()


func _generate_field():
	var rng = RandomNumberGenerator.new()

	for i in range(height*width):
		gem_field.append(rng.randi_range(0, gems.size()-1))


func _display_field():
	$Field.columns = width
	for j in range(height):
		for i in range(width):
			var gem_id = gem_field[j*width + i]
			var gem = gems[gem_id].duplicate()
			gem.visible = true
			$Field.add_child(gem)
