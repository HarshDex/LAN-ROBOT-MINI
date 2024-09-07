extends CharacterBody2D

@export var speed = 25
@export var gravity = 800
@export var ray_cast_length = 20

var direction = 1

@onready var animated_sprite = $AnimatedSprite
@onready var ray_cast_left = $RayCastLeft
@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_down_left = $RayCastDownLeft
@onready var ray_cast_down_right = $RayCastDownRight

func _physics_process(delta):
	velocity.y += gravity * delta

	if is_on_wall() or not ray_cast_down_left.is_colliding() or not ray_cast_down_right.is_colliding():
		direction *= -1

	if ray_cast_left.is_colliding() and direction == -1:
		direction = 1
	elif ray_cast_right.is_colliding() and direction == 1:
		direction = -1

	velocity.x = direction * speed
	move_and_slide()

	if velocity.x != 0:
		animated_sprite.play("walking")
	else:
		animated_sprite.play("idle")

	animated_sprite.flip_h = direction == -1
