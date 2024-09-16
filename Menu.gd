extends Node2D




func _on_teleportation_body_entered(body):
	if body is RigidBody2D:
		print("Rigid Body Entered Teleportation!")
		# Teleport the body using set_deferred
		body.set_deferred("global_position", $Teleportation2.global_position + Vector2(50, 0))
		body.set_deferred("linear_velocity", Vector2.ZERO)
		#$Teleportation/teleportation/TeleportSound.play()
		
	elif body is CharacterBody2D:
		print("Character Body Entered Teleportation!")
		body.global_position = $Teleportation2.global_position + Vector2(40, 0)
		#$Teleportation/teleportation/TeleportSound.play()

func _on_teleportation_2_body_entered(body):
	if body is RigidBody2D:
		print("Rigid Body Entered Teleportation!")
		
		# Teleport the body using set_deferred
		body.set_deferred("global_position", $Teleportation.global_position + Vector2(50, 0))
		body.set_deferred("linear_velocity", Vector2.ZERO)
		#$Teleportation/teleportation/TeleportSound.play()
	elif body is CharacterBody2D:
		print("Character Body Entered Teleportation!")
		body.global_position = $Teleportation.global_position + Vector2(40, 0)
		#$Teleportation/teleportation/TeleportSound.play()
