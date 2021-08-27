extends AnimationPlayer

func _ready():
	print("Animation Ready")
	#var match3 = $"/root/Node2D/Match3"
	#match3.connect("moved_gem", self, "animate_switch")
	
func _get_full_path(path_name):
	var path_string = ""
	for i in range(path_name.get_name_count()):
		path_string += path_name.get_name(i) + "/"
	return path_string.trim_suffix("/")

func _slide_gem_left(gem):
	var animation = Animation.new()
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, _get_full_path(get_path_to(gem)) + ":rect_position:x")
	animation.track_insert_key(track_index, 0.0, 0)
	animation.track_insert_key(track_index, 0.3, -55)
	print(get_path_to(gem))
	print(animation.track_get_path(track_index))
	
	add_animation("left_slide", animation)
	play("left_slide")
	remove_animation("left_slide")
	print("Animate Left")

func _slide_gem_right(gem):
	var animation = Animation.new()
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, _get_full_path(get_path_to(gem)) + ":rect_position:x")
	animation.track_insert_key(track_index, 0.0, 0)
	animation.track_insert_key(track_index, 0.3, 55)
	
	add_animation("right_slide", animation)
	play("right_slide")
	remove_animation("right_slide")
	print("Animate Right")
	
func _slide_gem_up(gem):
	var animation = Animation.new()
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, _get_full_path(get_path_to(gem)) + ":rect_position:y")
	animation.track_insert_key(track_index, 0.0, 0)
	animation.track_insert_key(track_index, 0.3, 55)
	
	add_animation("up_slide", animation)
	play("up_slide")
	remove_animation("up_slide")
	print("Animate Up")
	
func _slide_gem_down(gem):
	var animation = Animation.new()
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, _get_full_path(get_path_to(gem)) + ":rect_position:y")
	animation.track_insert_key(track_index, 0.0, 0)
	animation.track_insert_key(track_index, 0.3, -55)
	
	add_animation("down_slide", animation)
	play("down_slide")
	remove_animation("down_slide")
	print("Animate Down")
	
func animate_switch(gem1, gem2):
	print("Animate Switch")
	if gem1.field_pos.x > gem2.field_pos.x:
		_slide_gem_left(gem1)
		_slide_gem_right(gem2)
	elif gem1.field_pos.x < gem2.field_pos.x:
		_slide_gem_right(gem1)
		_slide_gem_left(gem2)
	elif gem1.field_pos.y > gem2.field_pos.y:
		_slide_gem_down(gem1)
		_slide_gem_up(gem2)
	elif gem1.field_pos.y < gem2.field_pos.y:
		_slide_gem_up(gem1)
		_slide_gem_down(gem2)
		
