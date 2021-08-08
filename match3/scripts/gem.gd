extends TextureRect

var field_pos = {"x": -1, "y": -1}
var match3 : Control = null


func _ready() -> void:
	pass


func _gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			match3.mouse_pressed_gem(self)
		else:
			match3.mouse_released_gem(self)


func init_gem(manager, x, y):
	field_pos.x = x
	field_pos.y = y
	match3 = manager
