extends CharacterBody2D

@onready var camera = $Camera2D
@onready var animated_sprite = $AnimatedSprite2D
@onready var point_light = $PointLight2D

const SPEED = 110.0
const JUMP_VELOCITY = -315.0
var push_force = 25.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var initial_light_position: Vector2
var initial_light_rotation: float

func _ready():
	if is_multiplayer_authority():
		camera.make_current()
	animated_sprite.play("idle")
	initial_light_position = point_light.position
	initial_light_rotation = point_light.rotation

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
		var direction = Input.get_axis("ui_left", "ui_right")
		var is_moving = abs(direction) > 0.0
		if is_moving:
			velocity.x = direction * SPEED
			animated_sprite.flip_h = direction < 0
			# Flip point light position and rotation
			if direction < 0:
				point_light.position.x = -abs(initial_light_position.x)
				point_light.rotation = initial_light_rotation + PI
			else:
				point_light.position.x = abs(initial_light_position.x)
				point_light.rotation = initial_light_rotation
			if animated_sprite.animation != "walking":
				animated_sprite.play("walking")
		else:
			if velocity.x != 0.0:
				velocity.x = move_toward(velocity.x, 0, SPEED)
			if animated_sprite.animation != "idle":
				animated_sprite.play("idle")

		# Move the character
		var previous_position = position
		var previous_velocity = velocity
		move_and_slide()

		# Handle collision with RigidBody2D
		var collisions = get_slide_collision_count()
		if collisions > 0:
			var space = get_world_2d().direct_space_state
			for index in collisions:
				var collision = get_slide_collision(index)
				if collision.get_collider() is RigidBody2D:
					var collider = collision.get_collider()
					var collision_normal = collision.get_normal()
					# Apply impulse to the RigidBody2D
					apply_impulse_to_rigidbody(collider, collision_normal)

		# Synchronize the player's state with other peers
		if is_multiplayer_authority():
			rpc("update_player_state", position, velocity)
		else:
			# Interpolate the player's position and velocity on non-authority peers
			position = lerp(position, previous_position, 0.2)
			velocity = lerp(velocity, previous_velocity, 0.2)

func apply_impulse_to_rigidbody(collider, collision_normal):
	# Apply impulse to the RigidBody2D locally
	collider.apply_central_impulse(-collision_normal * push_force)
	# Notify other peers to apply the impulse
	rpc("apply_impulse", collider.get_path(), -collision_normal * push_force)

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

@rpc("any_peer")
func player_died(player_id):
	# Notify the level script about player death
	$DeathSound.play()
	get_parent().rpc("player_died", player_id)
