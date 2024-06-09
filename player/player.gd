extends CharacterBody2D

@onready var camera = $Camera2D
@onready var animated_sprite = $AnimatedSprite2D

const SPEED = 110.0
const JUMP_VELOCITY = -315.0
var push_force = 25.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	if is_multiplayer_authority():
		camera.make_current()
	animated_sprite.play("idle")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		$JumpSound.play()

	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		animated_sprite.flip_h = direction < 0
		animated_sprite.play("walking")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animated_sprite.play("idle")

	# Move the character
	var previous_position = position
	move_and_slide()

	# Handle collision with RigidBody2D
	for index in range(get_slide_collision_count()):
		var collision = get_slide_collision(index)
		if collision.get_collider() is RigidBody2D:
			var collider = collision.get_collider()
			var collision_normal = collision.get_normal()
			# Apply impulse to the RigidBody2D locally
			collider.apply_central_impulse(-collision_normal * push_force)
			# Notify other peers to apply the impulse
	
			rpc("apply_impulse", collider.get_path(), -collision_normal * push_force)

	# Synchronize the player's position and velocity with clients
	if is_multiplayer_authority():
		rpc("update_player_state", position, velocity)

@rpc("any_peer")
func apply_impulse(collider_path, impulse):
	var collider = get_node(collider_path)
	if collider:
		collider.apply_central_impulse(impulse)

@rpc("unreliable")
func update_player_state(new_position, new_velocity):
	# Update player state on non-authority peers
	if not is_multiplayer_authority():
		position = new_position
		velocity = new_velocity

#Player Death
@rpc("any_peer")
func player_died(player_id):
	# Notify the level script about player death
	$DeathSound.play()
	get_parent().rpc("player_died", player_id)

