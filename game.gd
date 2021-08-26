extends Control

onready var character : TextureRect = $Background/GinPng
onready var dialog_box : Control = $Background/DialogueBox
onready var message_box : Control = $Background/DialogueBox/MessageBox
onready var info_panel : RichTextLabel = $NinePatchRect/RichTextLabel
onready var match3 = $Match3
onready var match3_cover : Control = $Match3/NinePatchRect
onready var music_player : AudioStreamPlayer = $MusicPlayer
onready var audio_player : AudioStreamPlayer = $AudioPlayer

var talk_queue = []
var dialog_ready = true
var target_score : int = 3200
var current_score : int = 0
var target_reached : bool = false
var last_score : int = 0
var max_move_count = 15
var move_count = 0
var talk_timer : float = 0
var rng = RandomNumberGenerator.new()

func _update_info():
	var info = "Score: {0} / {1}".format([current_score, target_score])
	if current_score >= target_score:
		info = "[color=lime]Score: {0} / {1}[/color]".format([current_score, target_score])
	info += "[color=#55ffffff] + {0}[/color]".format([last_score])
		
	info += "\n"
	
	var remain = max_move_count - move_count
	
	if remain == 0:
		info += "[color=red]Move Remains: {0}[/color]".format([remain])
	elif remain <= 3:
		info += "[color=yellow]Move Remains: {0}[/color]".format([remain])
	else:
		info += "Move Remains: {0}".format([remain])
	
	info_panel.bbcode_text = info


func _ready():
	_talk("Welcome to this simple Match 3 game.", "talk")
	_talk("I'm Gin Png the fox! A gaming enthusiast!", "talk")
	_talk("I'm here to help Puetsua to explain this game. This game is made in Godot.", "happy")
	_talk("It was a practice for Puetsua, so we don't have many features here.", "talk")
	_talk("On top left you can see your score and remaining moves.", "talk")
	_talk("That plus on the right of score mean the score you gained from last move.", "talk")
	_talk("Also if you don't like the music, you can turn off the audio on top right.", "talk")
	_talk("Enjoy~ :D", "happy")
	
	match3_cover.visible = false
	match3.generate_field()
	_update_info()
	rng.randomize()
	target_reached = false
	
	music_player.play()


func _process(delta):
	if dialog_ready:
		if talk_queue.size() > 0:
			_talk_execute(talk_queue[0]['message'], talk_queue[0]['expression'])
			talk_queue.pop_front()
		else:
			talk_timer += delta
			
	if talk_timer > 20.0:
		var rand = rng.randi_range(0, 4)
		if rand == 0:
			_talk("Haven't got any progress yet? You can actually move the gem even when they don't make a match.", "confused")
		elif rand == 1:
			_talk("I guess you might be curious about where I am. I'm in a coffee shop!", "talk")
		elif rand == 2:
			_talk("I have a shark friend who really likes mobile games. Too bad I'm a console gamer.", "talk")
		elif rand == 3:
			_talk("I heard that game design is very hard. You have to learn so much stuff to create a good game.", "talk")

func _talk(msg, expression):
	talk_queue.append({
		'message': msg,
		'expression': expression
	})


func _talk_execute(msg, expression):
	character.change_sprite(expression)
	
	dialog_box.ui_show()
	
	message_box.message = msg
	message_box.play()
	dialog_ready = false
	talk_timer = 0


func _on_DialogueBox_dialogue_done():
	yield(get_tree().create_timer(3.0), "timeout")
	dialog_ready = true
	if dialog_box.is_ui_visible() == true: 
		character.change_sprite("smile")
		dialog_box.ui_hide()


func _on_Match3_scored(score):
	last_score = score
	current_score += score
	_update_info()
	
	if talk_queue.size() > 5:
		talk_queue.clear()
		_talk("Wait. You're already playing? Looks like you know what you're doing.", "confused")
	else:
		if current_score > target_score and !target_reached:
			target_reached = true
			_talk("Hurray! You reached the target score! You can continue to play to get the score as high as possible.", "happy")
		elif last_score > 1000:
			_talk("Over 1000 in one move? Now that's a strategic move.", "talk")
		elif last_score > 700:
			_talk("Over 700! I don't have the luck to score that much in one move.", "talk")
		elif last_score > 500:
			_talk("Nice move!", "talk")
	
	if max_move_count - move_count <= 0:
		if current_score >= target_score:
			# win
			target_score = pow(current_score, 0.98)
			target_score = target_score - target_score % 100
			_talk("Congratulations! You reached the target score this round! Let's try for the next target score.", "happy")
		else:
			# lose
			_talk("That's fine! I know it's hard to reach that score at this point. You can try it again if you want!", "happy")
			
		match3_cover.visible = true
		audio_player.play()
		
		yield(get_tree().create_timer(3), "timeout")
		
		match3.generate_field()
		match3_cover.visible = false
		current_score = 0
		last_score = 0
		move_count = 0
		target_reached = false
		
		_update_info()


func _on_Match3_moved_gem():
	move_count += 1
	
	if max_move_count - move_count == 3:
		if target_score > current_score:
			_talk("Three moves remaining, it's your last chance to reach target score.", "talk")
		else:
			_talk("Three moves remaining! Try to get as many points as possible!", "happy")
	
	_update_info()


func _on_CheckButton_toggled(isOn):
	if isOn:
		music_player.play()
	else:
		music_player.stop()
