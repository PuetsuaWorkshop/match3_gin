extends Control

onready var character : TextureRect = $Background/GinPng
onready var dialog_box : Control = $Background/DialogueBox
onready var message_box : Control = $Background/DialogueBox/MessageBox

var talk_queue = []
var dialog_ready = true

func _ready():
	_talk("Test 123 [b]Stronk[/b] Fox Gin!", "talk")
	_talk("Test 567 [b]Stronk[/b] Fox Gin!", "talk")
	_talk("Test 689 [b]Stronk[/b] Fox Gin!", "talk")


func _process(delta):
	if dialog_ready:
		if talk_queue.size() > 0:
			_talk_execute(talk_queue[0]['message'], talk_queue[0]['expression'])
			talk_queue.pop_front()


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


func _on_DialogueBox_dialogue_done():
	yield(get_tree().create_timer(3.0), "timeout")
	dialog_ready = true
	if dialog_box.is_ui_visible() == true: 
		character.change_sprite("smile")
		dialog_box.ui_hide()
