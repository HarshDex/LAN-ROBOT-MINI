extends CharacterBody2D

@onready var camera = $Camera2D
@onready var animated_sprite = $AnimatedSprite2D
@onready var point_light = $PointLight2D

const SPEED = 20.0
const JUMP_VELOCITY = -315.0
var push_force = 25.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")



func _physics_process(delta):
	if is_multiplayer_authority():
		# Add the gravity.

		if not is_on_floor():
			velocity.y += gravity * delta

		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			$JumpSound.play()

		# Get the input direction and handle the movement/deceleration.
		
		velocity.x = SPEED
		move_and_slide()

		# Handle collision with RigidBody2D
		
