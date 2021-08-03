extends Control

onready var character : TextureRect = $Background/GinPng
onready var dialog_box : Control = $Background/DialogueBox
onready var message_box : Control = $Background/DialogueBox/MessageBox


func _ready():
	message_box.message = "Test 123 [b]Stronk[/b] Fox Gin!"
	message_box.play()


func _process(delta):
	pass


func _on_MessageBox_message_done():
	yield(get_tree().create_timer(3.0), "timeout")
	character.change_sprite("smile")
	dialog_box.hide()
