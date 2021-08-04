extends NinePatchRect

signal dialogue_done

onready var fade = $UIFade

func is_ui_visible():
	return modulate.a > 0


func ui_show():
	if modulate.a < 1:
		fade.fade_show()
	
	
func ui_hide():
	if modulate.a > 0:
		fade.fade_hide()


func _on_MessageBox_message_done():
	emit_signal("dialogue_done")
