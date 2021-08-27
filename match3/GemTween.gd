extends Tween


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _get_full_path(path_name):
	var path_string = ""
	for i in range(path_name.get_name_count()):
		path_string += path_name.get_name(i) + "/"
	return path_string.trim_suffix("/")

func slide_gem_left(gem):
	var x_pos = gem.rect_position.x
	interpolate_property(gem, "rect_position:x" , x_pos, x_pos - 55, 0.3)
	start()

func slide_gem_right(gem):
	var x_pos = gem.rect_position.x
	interpolate_property(gem, "rect_position:x" , x_pos, x_pos + 55, 0.3)
	start()
	
func slide_gem_up(gem):
	var y_pos = gem.rect_position.y
	interpolate_property(gem, "rect_position:y" , y_pos, y_pos + 55, 0.3)
	start()
	
func slide_gem_down(gem):
	var y_pos = gem.rect_position.y
	interpolate_property(gem, "rect_position:y" , y_pos, y_pos - 55, 0.3)
	start()

func animate_switch(gem1, gem2):
	print("Animate Switch")
	if gem1.field_pos.x > gem2.field_pos.x:
		slide_gem_left(gem1)
		slide_gem_right(gem2)
	elif gem1.field_pos.x < gem2.field_pos.x:
		slide_gem_right(gem1)
		slide_gem_left(gem2)
	elif gem1.field_pos.y > gem2.field_pos.y:
		slide_gem_down(gem1)
		slide_gem_up(gem2)
	elif gem1.field_pos.y < gem2.field_pos.y:
		slide_gem_up(gem1)
		slide_gem_down(gem2)
