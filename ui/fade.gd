extends Node

export var fade_time : float = 0.2

onready var ui : Control = get_parent()
onready var tween : Tween = $Tween


func fade_show():
	if tween.is_active():
		tween.stop_all()
		
	tween.interpolate_property(ui, 'modulate:a', 
		ui.modulate.a, 1.0, fade_time,
		Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()
	
	
func fade_hide():
	if tween.is_active():
		tween.stop_all()
	
	tween.interpolate_property(ui, 'modulate:a', 
		ui.modulate.a, 0.0, fade_time,
		Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()
