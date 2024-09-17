extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_restart_settings_pressed():
	get_tree().reload_current_scene()


func _on_about_settings_pressed():
	$SettingsPanel/AboutPanel.visible = true
	$SettingsPanel/SoundPanel.visible = false



func _on_sound_settings_pressed():
	$SettingsPanel/SoundPanel.visible = true
	$SettingsPanel/AboutPanel.visible = false
	


func _on_settings_back_pressed():
	$".".visible = false


func _on_sound_back_pressed():
	$SettingsPanel/SoundPanel.visible = false


func _on_about_back_pressed():
	$SettingsPanel/AboutPanel.visible = false
