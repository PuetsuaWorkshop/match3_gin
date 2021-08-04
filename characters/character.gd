extends TextureRect

export var character_name : String = "cafe"
export var default_expression : String = "smile"

var _expression = default_expression
var _new_texture = null
var _process = null

onready var anim_player : AnimationPlayer = $AnimationPlayer

signal on_animation_peak


func change_sprite(expression):
	var path = "res://characters/{0}_{1}.png".format([character_name, expression])
	_new_texture = load(path)
	
	if _process != null:
		anim_player.stop()
	_process = _change_sprite_process()


func _ready():
	self.texture = load("res://characters/{0}_{1}.png".format([character_name, _expression]))


func _change_sprite_process():
	anim_player.play("switching")
	yield(self, "on_animation_peak")
	self.texture = _new_texture
	_process = null


func _on_animation_peak():
	emit_signal("on_animation_peak")
