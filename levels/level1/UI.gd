extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_pause_pressed():
	$"../Menu".visible = true


func _on_about_back_pressed():
	$"../Menu/SettingsPanel/AboutPanel".visible = false


func _on_sound_back_pressed():
	$"../Menu/SettingsPanel/SoundPanel".visible = false
