extends Node2D
# Called when the node enters the scene tree for the first time.
func _ready():
	if multiplayer.is_server():
		$AnimationPlayer.play("rotation")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_transition_player_animation_finished(anim_name):
	$"../TransitionPlayer".play("transition")
	get_tree().change_scene_to_file("res://lobby.tscn")


func _on_button_pressed():
	$"../TransitionPlayer".play("transition")
