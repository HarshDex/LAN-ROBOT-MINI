extends Area2D

func _on_body_entered(body):
	$AnimationPlayer.play("pressed")
	print("pressed")

func _on_body_exited(body):
	$AnimationPlayer.play("idle")
	print("unpressed")
