extends Area2D

@export var bounce_height = 500.0

func _physics_process(delta):
	for body in get_overlapping_bodies():
		if body.is_in_group("boxes"):
			print("Box collided")
			if body is RigidBody2D:
				var impulse = Vector2(0, -bounce_height/4 * body.mass)
				body.apply_central_impulse(impulse)

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("Player entered")
		if body is CharacterBody2D:
			body.velocity.y = -bounce_height
