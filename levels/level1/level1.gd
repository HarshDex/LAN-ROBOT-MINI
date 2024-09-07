extends Node2D

@export var spawn_points: Array[Vector2] = [Vector2(78, 110), Vector2(75, 110)]
@export var player_scene: PackedScene

@onready var animation_player = $Platforms/PlatformAnimation

var checkpoint_position = null

func _ready():
	load_checkpoint()
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(_on_player_connected)
		_spawn_player(1)  # Spawn the host player with peer_id 1

	# Animations
	# Check if the current peer ais the server (host) and has multiplayer authority
	if is_multiplayer_authority():
		# Start playing the animation automatically on the host
		animation_player.play("platforms")
		$RotatingLasers/RotatingLaser/AnimationPlayer.play("rotation")
		
func _on_player_connected(peer_id):
	if multiplayer.is_server():
		_spawn_player(peer_id)

func _spawn_player(peer_id):
	var spawn_point = get_spawn_point(peer_id)
	rpc("_spawn_player_remotely", peer_id, spawn_point)

@rpc("call_local")
func _spawn_player_remotely(peer_id, spawn_point):
	print("Spawning player for peer: ", peer_id)

	var player = player_scene.instantiate()

	# Check if a player with the same rpc_id already exists
	var existing_player = get_node_or_null("player_" + str(peer_id))
	if existing_player:
		print("Player with peer ID ", peer_id, " already exists. Removing existing player.")
		existing_player.queue_free()

	# Load the checkpoint position
	var checkpoint_position = load_checkpoint()
	print("Checkpoint position: ", checkpoint_position)

	var offset = Vector2.ZERO
	if peer_id != 1:  # Apply offset to players other than peer ID 1
		offset = Vector2(50, 0)

	if checkpoint_position:
		player.position = checkpoint_position + offset
	else:
		player.position = spawn_point + offset

	player.name = "player_" + str(peer_id)  # Set the player name
	print("Player name: ", player.name)

	player.set_multiplayer_authority(peer_id)  # Set multiplayer authority for the spawned player
	print("Multiplayer authority set for player: ", player)

	add_child(player)
	print("Player added to the scene.")

func get_spawn_point(peer_id):
	var peer_index = peer_id - 1
	var spawn_point = spawn_points[peer_index % spawn_points.size()]
	
	# Offset the spawn point for players other than peer ID 1
	if peer_id != 1:
		spawn_point += Vector2(100, 0)  # Adjust the offset as needed
	
	return spawn_point


func _on_checkpoint_body_entered(body):
	if body.is_in_group("player"):
		var position = body.position
		save_checkpoint(position)

func save_checkpoint(position):
	# Save the checkpoint position
	checkpoint_position = position
	var file_path = "user://checkpoint.save"
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file != null:
		file.store_var(checkpoint_position)
		print("Checkpoint saved successfully.")
		file.close()
	else:
		print("Error opening checkpoint file for writing.")

func load_checkpoint():
	# Load the checkpoint position
	var file_path = "user://checkpoint.save"
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file != null:
			var status = file.get_error()
			if status == OK:
				checkpoint_position = file.get_var()
				print("Checkpoint loaded successfully. Position: ", checkpoint_position)
			else:
				print("Error reading checkpoint file: ", status)
			file.close()
		else:
			print("Error opening checkpoint file for reading.")
	else:
		print("Checkpoint file does not exist.")

	# Return the loaded checkpoint position or null if it couldn't be loaded
	return checkpoint_position

# Player Death Code
func _on_death_area_body_entered(body):
	if body.is_in_group("player"):
		print("death")
		var player_id = int(str(body.name).replace("player_", ""))
		body.rpc("player_died", player_id)

@rpc("any_peer", "call_local")
func player_died(player_id):
	# Respawn both players at the last checkpoint or spawn points
	$ResetLevel.play("reset");
	var checkpoint_position = load_checkpoint()
	for player in get_tree().get_nodes_in_group("player"):
		var peer_id = int(str(player.name).replace("player_", ""))
		var spawn_point = get_spawn_point(peer_id)
		
		var offset = Vector2.ZERO
		if peer_id != 1:  # Apply offset to players other than peer ID 1
			offset = Vector2(100, 0)  # Adjust the offset as needed
		
		if player.is_multiplayer_authority():
			if checkpoint_position:
				player.position = checkpoint_position + offset
			else:
				player.position = spawn_point + offset
		else:
			player.rpc("respawn_player", checkpoint_position, spawn_point, offset)

@rpc("any_peer", "call_local")
func respawn_player(checkpoint_position, spawn_point, offset):
	if checkpoint_position:
		position = checkpoint_position + offset
	else:
		position = spawn_point + offset



#<--- Door Related Code ---->


func _on_door_1_trigger_body_entered(_body):
	print('trigger 1 activated')
	$DoorNodes/DoorAnimation.play("door1")
	$DoorNodes/Door1Trigger.visible = false

func _on_door_1_trigger_2_body_entered(_body):
	print('trigger 2 activated')
	$DoorNodes/DoorAnimation.play("door2")
	$DoorNodes/Door1Trigger2.visible = false
 
func _on_door_trigger_3_body_entered(body):
	print('trigger 3 activated')
	$DoorNodes/DoorAnimation.play("door3")
	$DoorNodes/DoorTrigger3.visible = false
	
func _on_door_trigger_4_body_entered(body):
	print('trigger 4 activated')
	$DoorNodes/DoorAnimation.play("door4")
	$DoorNodes/DoorTrigger4.visible = false
	
func _on_door_trigger_5_body_entered(body):
	print('trigger 4 activated')
	$DoorNodes/DoorAnimation.play("door5")
	$DoorNodes/DoorTrigger5.visible = false
#<--- Door Related Code ---->


#<--- Teleportation Related Code ---->
func _on_teleportation_body_entered(body):
	if body is RigidBody2D:
		print("Rigid Body Entered Teleportation!")
		# Teleport the body using set_deferred
		body.set_deferred("global_position", $Teleportation/teleportation2.global_position + Vector2(50, 0))
		body.set_deferred("linear_velocity", Vector2.ZERO)
		$Teleportation/teleportation/TeleportSound.play()
		
	elif body is CharacterBody2D:
		print("Character Body Entered Teleportation!")
		body.global_position = $Teleportation/teleportation2.global_position + Vector2(40, 0)
		$Teleportation/teleportation/TeleportSound.play()

func _on_teleportation_2_body_entered(body):
	if body is RigidBody2D:
		print("Rigid Body Entered Teleportation!")
		
		# Teleport the body using set_deferred
		body.set_deferred("global_position", $Teleportation/teleportation.global_position + Vector2(50, 0))
		body.set_deferred("linear_velocity", Vector2.ZERO)
		$Teleportation/teleportation/TeleportSound.play()
	elif body is CharacterBody2D:
		print("Character Body Entered Teleportation!")
		body.global_position = $Teleportation/teleportation.global_position + Vector2(40, 0)
		$Teleportation/teleportation/TeleportSound.play()


func _on_teleportation_3_body_entered(body):
	if body is RigidBody2D:
		print("Rigid Body Entered Teleportation!")
		# Teleport the body using set_deferred
		body.set_deferred("global_position", $Teleportation/teleportation4.global_position + Vector2(50, 0))
		body.set_deferred("linear_velocity", Vector2.ZERO)
		$Teleportation/teleportation4/TeleportSound.play()
	elif body is CharacterBody2D:
		print("Character Body Entered Teleportation!")
		body.global_position = $Teleportation/teleportation4.global_position + Vector2(40, 0)
		$Teleportation/teleportation4/TeleportSound.play()
		
func _on_teleportation_4_body_entered(body):
	if body is RigidBody2D:
		print("Rigid Body Entered Teleportation!")
		
		# Teleport the body using set_deferred
		body.set_deferred("global_position", $Teleportation/teleportation3.global_position + Vector2(50, 0))
		body.set_deferred("linear_velocity", Vector2.ZERO)
		$Teleportation/teleportation3/TeleportSound.play()
	elif body is CharacterBody2D:
		print("Character Body Entered Teleportation!")
		body.global_position = $Teleportation/teleportation3.global_position + Vector2(40, 0)
		$Teleportation/teleportation3/TeleportSound.play()
#<--- Teleportation Related Code ---->




#<--- DoorWeight Related Code ---->		
func _on_door_trigger_weight_body_entered(body):
	if body.is_in_group("player") or body.is_in_group("boxes"):
		$DoorWeight/DoorWeightAnimation.play("doorWeight1_enter");
	

func _on_door_trigger_weight_body_exited(body):
	if body.is_in_group("player") or body.is_in_group("boxes"):
		$DoorWeight/DoorWeightAnimation.play("doorWeight1_exit");
		
		
		
func _on_door_trigger_weight_3_body_entered(body):
	if body.is_in_group("player") or body.is_in_group("boxes"):
		$DoorWeight/DoorWeightAnimation.play("doorWeight2_enter")


func _on_door_trigger_weight_3_body_exited(body):
	if body.is_in_group("player") or body.is_in_group("boxes"):
		$DoorWeight/DoorWeightAnimation.play("doorWeight2_exit")
#<--- DoorWeight Related Code ---->



#<--- DoorWeight Lazer Related Code ---->

func _on_lazer_trigger_weight_body_entered(body):
	if body.is_in_group("player") or body.is_in_group("boxes"):
		$LazerWeights/Laser.set_scale(Vector2.ZERO)

func _on_lazer_trigger_weight_body_exited(body):
	if body.is_in_group("player") or body.is_in_group("boxes"):
		$LazerWeights/Laser.set_scale(Vector2(2, 1))
		

func _on_death_laser_body_entered(body):
	print("Player dead af")
	if body.is_in_group("player"):
		print("death")
		var player_id = int(str(body.name).replace("player_", ""))
		body.rpc("player_died", player_id)
		
#<--- DoorWeight Lazer Related Code ---->



#<--- Enemy Related Code ---->

func _on_death_area_2d_body_entered(body):
	if body.is_in_group("player"):
		print("death")
		var player_id = int(str(body.name).replace("player_", ""))
		body.rpc("player_died", player_id)

#<--- Enemy Related Code ---->
