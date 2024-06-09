extends Node2D

#<--- Door Related Code ---->
func _on_door_1_trigger_body_entered(_body):
	$DoorAnimation.play("door1")
	$Door1Trigger.visible = false
	
