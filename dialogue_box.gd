extends NinePatchRect

onready var fade = $UIFade

func ui_show():
	fade.fade_show()
	
func ui_hide():
	fade.fade_hide()
