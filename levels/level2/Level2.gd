extends Node2D

@export var spawn_points: Array[Vector2] = [Vector2(86, 300), Vector2(90, 300)]
#@export var spawn_points: Array[Vector2] = [Vector2(1117, 125), Vector2(1111, 120)]
@export var player_scene: PackedScene

@onready var animation_player = $Platforms/PlatformAnimation

var checkpoint_position = null

func _ready():
	load_checkpoint()
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(_on_player_connected)
		_spawn_player(1)  # Spawn the host player with peer_id 1


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
	print("Player dead af")
	if body.is_in_group("player"):
		print("death")
		var player_id = int(str(body.name).replace("player_", ""))
		body.rpc("player_died", player_id)

@rpc("any_peer", "call_local")
func player_died(player_id):
	$ResetLevel.play("reset")
	# Respawn both players at the last checkpoint or spawn points
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
var door1_interaction = false
var door2_interaction = false
var door3_interaction = false
var door4_interaction = false
var door5_interaction = false
var door6_interaction = false
var door7_interaction = false
var door8_interaction = false
var door9_interaction = false
var door10_interaction = false
var door11_interaction = false
var door12_interaction = false
var door13_interaction = false
var door14_interaction = false


var _door_states = {
	"door1": true,
	"door2": false,
	"door3": false,
	"door4": false,
	"door5": false,
	"door6": false,
	"door7": false,
	"door8": false,
	"door9": false,
	"door10": false,
	"door11": false,
	"door12": false,
	"door13": false,
	"door14": false
}



#<---for laser---->
var laser_interaction = false
var laser1_interaction = false
var laser2_interaction = false
var laser10_interaction = false
var laser4_interaction = false
var laser5_interaction = false
var laser6_interaction = false
var laser7_interaction = false


func _on_laser_death_area_body_entered(body):
	if(laser_interaction == false):
		print("Player dead af")
		if body.is_in_group("player"):
			print("death")
			var player_id = int(str(body.name).replace("player_", ""))
			body.rpc("player_died", player_id)



func _input(event):
	#<---door related---->
	if Input.is_action_just_pressed("interact"):
			for i in range(1, 11):  # Doors 1 to 9
				if get("door{0}_interaction".format([i])) == true:
					rpc("activate_door", i)
		
	if Input.is_action_just_pressed("interact") and door2_interaction == true:
		$DoorNodes/DoorAnimation.play("door2")
		$DoorNodes/Door2Trigger.visible = false

	if Input.is_action_just_pressed("interact") and door4_interaction == true:
		$DoorNodes/DoorAnimation.play("door4")
		$DoorNodes/Door4Trigger.visible = false
		
	if Input.is_action_just_pressed("interact") and door5_interaction == true:
		$DoorNodes/DoorAnimation.play("door5")
		$DoorNodes/Door5Trigger.visible = false
		
	if Input.is_action_just_pressed("interact") and door6_interaction == true:
		$DoorNodes/DoorAnimation.play("door6")
		$DoorNodes/Door6Trigger.visible = false
	
	if Input.is_action_just_pressed("interact") and door7_interaction == true:
		$DoorNodes/DoorAnimation.play("door7")
		$DoorNodes/Door7Trigger.visible = false
		
	if Input.is_action_just_pressed("interact") and door8_interaction == true:
		$DoorNodes/DoorAnimation.play("door8")
		$DoorNodes/Door8Trigger.visible = false
		
	if Input.is_action_just_pressed("interact") and door9_interaction == true:
		$DoorNodes/DoorAnimation.play("door9")
		$DoorNodes/Door9Trigger.visible = false
		
	if Input.is_action_just_pressed("interact") and door10_interaction == true:
		$DoorNodes/DoorAnimation.play("door10")
		$DoorNodes/Door10Trigger.visible = false
			
	#<---Door related---->
	
	#<----laser related---->
	if Input.is_action_just_pressed("interact") and laser1_interaction == true:
		$LaserTriggers/Laser.set_scale(Vector2.ZERO)
		$LaserTriggers/Laser1Trigger.visible = false
		
	if Input.is_action_just_pressed("interact") and laser2_interaction == true:
		$LaserTriggers/Laser2.set_scale(Vector2.ZERO)
		$LaserTriggers/Laser2Trigger.visible = false
	
	if Input.is_action_just_pressed("interact") and laser10_interaction == true:
		$LaserTriggers/Laser10.set_scale(Vector2.ZERO)
		$LaserTriggers/Laser10Trigger.visible = false
	#<----laser related---->

	
	
func _on_door_1_trigger_body_entered(body):
	if body.is_in_group("player"):
		$DoorNodes/Door1Trigger/Label.visible = true
		door1_interaction = true

func _on_door_1_trigger_body_exited(_body):
	$DoorNodes/Door1Trigger/Label.visible = false
	door1_interaction = false


func _on_door_2_trigger_body_entered(body):
	if body.is_in_group("player"):
		$DoorNodes/Door2Trigger/Label.visible = true
		door2_interaction = true


func _on_door_2_trigger_body_exited(_body):
	$DoorNodes/Door2Trigger/Label.visible = false
	door2_interaction = false


func _on_door_4_trigger_body_entered(body):
	if body.is_in_group("player"):
		$DoorNodes/Door4Trigger/Label.visible = true
		door4_interaction = true


func _on_door_4_trigger_body_exited(_body):
	$DoorNodes/Door4Trigger/Label.visible = false
	door4_interaction = false



func _on_door_5_trigger_body_entered(body):
	if body.is_in_group("player"):
		$DoorNodes/Door5Trigger/Label.visible = true
		door5_interaction = true


func _on_door_5_trigger_body_exited(_body):
	$DoorNodes/Door5Trigger/Label.visible = false
	door5_interaction = false
	
func _on_door_6_trigger_body_entered(body):
	if body.is_in_group("player"):
		$DoorNodes/Door6Trigger/Label.visible = true
		door6_interaction = true
	
func _on_door_6_trigger_body_exited(body):
	$DoorNodes/Door6Trigger/Label.visible = false
	door6_interaction = false
	

func _on_door_7_trigger_body_entered(body):
	if body.is_in_group("player"):
		$DoorNodes/Door7Trigger/Label.visible = true
		door7_interaction = true
 

func _on_door_7_trigger_body_exited(body):
	$DoorNodes/Door7Trigger/Label.visible = false
	door7_interaction = false
	
func _on_door_8_trigger_body_entered(body):
	if body.is_in_group("player"):
		$DoorNodes/Door8Trigger/Label.visible = true
		door8_interaction = true
		
func _on_door_8_trigger_body_exited(body):
	$DoorNodes/Door8Trigger/Label.visible = false
	door8_interaction = false
	
	
func _on_door_9_trigger_body_entered(body):
	if body.is_in_group("player"):
		$DoorNodes/Door9Trigger/Label.visible = true
		door9_interaction = true

func _on_door_9_trigger_body_exited(body):
	$DoorNodes/Door9Trigger/Label.visible = false
	door9_interaction = false


func _on_door_10_trigger_body_entered(body):
	if body.is_in_group("player"):
		$DoorNodes/Door10Trigger/Label.visible = true
		door10_interaction = true
		

func _on_door_10_trigger_body_exited(body):
	$DoorNodes/Door10Trigger/Label.visible = false
	door10_interaction = false
	

func _on_door_11_trigger_body_entered(body):
	if body.is_in_group("player"):
		$DoorNodes/Door11Trigger/Label.visible = true
		door11_interaction = true
		
func _on_door_11_trigger_body_exited(body):
	$DoorNodes/Door11Trigger/Label.visible = false
	door11_interaction = false
	
	
func _on_door_12_trigger_body_entered(body):
	if body.is_in_group("player"):
		$DoorNodes/Door12Trigger/Label.visible = true
		door12_interaction = true
		
func _on_door_12_trigger_body_exited(body):
	$DoorNodes/Door12Trigger/Label.visible = false
	door12_interaction = false
	
func _on_door_13_trigger_body_entered(body):
	if body.is_in_group("player"):
		$DoorNodes/Door13Trigger/Label.visible = true
		door13_interaction = true
		
func _on_door_13_trigger_body_exited(body):
	$DoorNodes/Door13Trigger/Label.visible = false
	door13_interaction = false
	
func _on_door_14_trigger_body_entered(body):
	if body.is_in_group("player"):
		$DoorNodes/Door14Trigger/Label.visible = true
		door14_interaction = true
		
func _on_door_14_trigger_body_exited(body):
	$DoorNodes/Door14Trigger/Label.visible = false
	door14_interaction = false
	
#<--- Door Related Code ---->



#<--- DoorWeight Related Code ---->		

func _on_door_3_weight_trigger_body_entered(body):
	if body.is_in_group("player") or body.is_in_group("boxes"):
		print("player entered in tigger")
		$DoorNodes/DoorAnimation.play("door3")

func _on_door_3_weight_trigger_body_exited(body):
	$DoorNodes/DoorAnimation.play("door3_closed")

func _on_door_4_weight_trigger_body_entered(body):
	if body.is_in_group("player") or body.is_in_group("boxes"):
		$DoorNodes/DoorAnimation.play("door4")

func _on_door_4_weight_trigger_body_exited(body):
	$DoorNodes/DoorAnimation.play("door4_closed")

func _on_door_5_weight_trigger_body_entered(body):
	if body.is_in_group("player") or body.is_in_group("boxes"):
		$DoorNodes/DoorAnimation.play("door5")

func _on_door_5_weight_trigger_body_exited(body):
	$DoorNodes/DoorAnimation.play("door5_closed")


func _on_door_6_weight_trigger_body_entered(body):
	if body.is_in_group("player") or body.is_in_group("boxes"):
		$DoorNodes/DoorAnimation.play("door6")

func _on_door_6_weight_trigger_body_exited(body):
	$DoorNodes/DoorAnimation.play("door6_closed")

func _on_door_8_weight_trigger_body_entered(body):
	if body.is_in_group("player") or body.is_in_group("boxes"):
		$DoorNodes/DoorAnimation.play("door8")


func _on_door_8_weight_trigger_body_exited(body):
		$DoorNodes/DoorAnimation.play("door8_closed")


func _on_door_9_weight_trigger_body_entered(body):
	if body.is_in_group("player") or body.is_in_group("boxes"):
		$DoorNodes/DoorAnimation.play("door9")


func _on_door_9_weight_trigger_body_exited(body):
	$DoorNodes/DoorAnimation.play("door9_closed")


func _on_door_10_weight_trigger_body_entered(body):
	if body.is_in_group("player") or body.is_in_group("boxes"):
		$DoorNodes/DoorAnimation.play("door10")


func _on_door_10_weight_trigger_body_exited(body):
	$DoorNodes/DoorAnimation.play("door10_closed")


func _on_door_11_weight_trigger_body_entered(body):
	if body.is_in_group("player") or body.is_in_group("boxes"):
		$DoorNodes/DoorAnimation.play("door11")

func _on_door_11_weight_trigger_body_exited(body):
	$DoorNodes/DoorAnimation.play("door11_closed")


func _on_door_12_weight_trigger_body_entered(body):
	if body.is_in_group("player") or body.is_in_group("boxes"):
		$DoorNodes/DoorAnimation.play("door12")

func _on_door_12_weight_trigger_body_exited(body):
	$DoorNodes/DoorAnimation.play("door12_closed")

func _on_door_15_weight_trigger_body_entered(body):
	if body.is_in_group("player") or body.is_in_group("boxes"):
		print('body entered')
		$DoorNodes/DoorAnimation.play("door15")

func _on_door_15_weight_trigger_body_exited(body):
	$DoorNodes/DoorAnimation.play("door15_closed")


#<--- DoorWeight Related Code ---->



#<--- Laser Trigger related code ---->

func _on_death_laser_body_entered(body):
	print("Player dead af")
	if body.is_in_group("player"):
		print("death")
		var player_id = int(str(body.name).replace("player_", ""))
		body.rpc("player_died", player_id)


func _on_laser_1_trigger_body_entered(_body):
	$LaserTriggers/Laser1Trigger/Label.visible = true
	laser1_interaction = true
	

func _on_laser_2_trigger_body_entered(body):
	$LaserTriggers/Laser2Trigger/Label.visible = true
	laser2_interaction = true
	


	
func _on_laser_10_trigger_body_entered(body):
	if body.is_in_group("player"):
		$LaserTriggers/Laser10Trigger/label.visible = true
		laser10_interaction = true
		
func _on_laser_10_trigger_body_exited(body):
	$LaserTriggers/Laser10Trigger/label.visible = true
	laser10_interaction = true


#<--- Laser Trigger related code ---->



#<--- Laser Weight Trigger related code ---->

func _on_laser_1_trigger_weight_body_entered(body):
	if body.is_in_group("player") or body.is_in_group("boxes"):
		laser1_interaction = true
		laser_interaction = true
		$LaserTriggers/Laser.visible = false
		$LaserTriggers/Laser/CollisionShape2D.disabled = true


func _on_laser_1_trigger_weight_body_exited(body):
	laser_interaction = false
	$LaserTriggers/Laser.visible = true
	$LaserTriggers/Laser/CollisionShape2D.disabled = false
	

func _on_laser_2_trigger_weight_body_entered(body):
	if body.is_in_group("player") or body.is_in_group("boxes"):
		laser_interaction = true
		laser2_interaction = false
		$LaserTriggers/Laser2.visible = false


func _on_laser_2_trigger_weight_body_exited(body):
	$LaserTriggers/Laser2.visible = true
	laser_interaction = false
	


#<--- Laser Weight Trigger related code ---->

#<--- teleportation related code--->
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
		$Teleportation/teleportation2/TeleportSound.play()
	elif body is CharacterBody2D:
		print("Character Body Entered Teleportation!")
		body.global_position = $Teleportation/teleportation.global_position + Vector2(40, 0)
		$Teleportation/teleportation2/TeleportSound.play()

func _on_teleportation_3_body_entered(body):
	if body is RigidBody2D:
		print("Rigid Body Entered Teleportation!")
		# Teleport the body using set_deferred
		body.set_deferred("global_position", $Teleportation/teleportation4.global_position + Vector2(50, 0))
		body.set_deferred("linear_velocity", Vector2.ZERO)
		$Teleportation/teleportation3/TeleportSound.play()
	elif body is CharacterBody2D:
		print("Character Body Entered Teleportation!")
		body.global_position = $Teleportation/teleportation4.global_position + Vector2(40, 0)
		$Teleportation/teleportation3/TeleportSound.play()
	

func _on_teleportation_4_body_entered(body):
	if body is RigidBody2D:
		print("Rigid Body Entered Teleportation!")
		# Teleport the body using set_deferred
		body.set_deferred("global_position", $Teleportation/teleportation3.global_position + Vector2(50, 0))
		body.set_deferred("linear_velocity", Vector2.ZERO)
		$Teleportation/teleportation4/TeleportSound.play
	elif body is CharacterBody2D:
		print("Character Body Entered Teleportation!")
		body.global_position = $Teleportation/teleportation3.global_position + Vector2(40, 0)
		$Teleportation/teleportation4/TeleportSound.play()
 

func _on_teleportation_5_body_entered(body):
	if body is RigidBody2D:
		print("Rigid Body Entered Teleportation!")
		# Teleport the body using set_deferred
		body.set_deferred("global_position", $Teleportation/teleportation6.global_position + Vector2(50, 0))
		body.set_deferred("linear_velocity", Vector2.ZERO)
		$Teleportation/teleportation5/TeleportSound.play
	elif body is CharacterBody2D:
		print("Character Body Entered Teleportation!")
		body.global_position = $Teleportation/teleportation6.global_position + Vector2(40, 0)
		$Teleportation/teleportation5/TeleportSound.play()
		

func _on_teleportation_6_body_entered(body):
	if body is RigidBody2D:
		print("Rigid Body Entered Teleportation!")
		# Teleport the body using set_deferred
		body.set_deferred("global_position", $Teleportation/teleportation5.global_position + Vector2(50, 0))
		body.set_deferred("linear_velocity", Vector2.ZERO)
		$Teleportation/teleportation6/TeleportSound.play
	elif body is CharacterBody2D:
		print("Character Body Entered Teleportation!")
		body.global_position = $Teleportation/teleportation5.global_position + Vector2(40, 0)
		$Teleportation/teleportation6/TeleportSound.play()

func _on_teleportation_7_body_entered(body):
	if body is RigidBody2D:
		print("Rigid Body Entered Teleportation!")
		body.set_deferred("global_position", $Teleportation/teleportation8.global_position + Vector2(50, 0))
		body.set_deferred("linear_velocity", Vector2.ZERO)
		$Teleportation/teleportation7/TeleportSound.play
	elif body is CharacterBody2D:
		print("Character Body Entered Teleportation!")
		body.global_position = $Teleportation/teleportation8.global_position + Vector2(40, 0)
		$Teleportation/teleportation7/TeleportSound.play()
		
func _on_teleportation_8_body_entered(body):
	if body is RigidBody2D:
		print("Rigid Body Entered Teleportation!")
		body.set_deferred("global_position", $Teleportation/teleportation7.global_position + Vector2(50, 0))
		body.set_deferred("linear_velocity", Vector2.ZERO)
		$Teleportation/teleportation8/TeleportSound.play
	elif body is CharacterBody2D:
		print("Character Body Entered Teleportation!")
		body.global_position = $Teleportation/teleportation7.global_position + Vector2(40, 0)
		$Teleportation/teleportation8/TeleportSound.play()
		
func _on_teleportation_9_body_entered(body):
	if body is RigidBody2D:
		print("Rigid Body Entered Teleportation!")
		body.set_deferred("global_position", $Teleportation/teleportation10.global_position + Vector2(50, 0))
		body.set_deferred("linear_velocity", Vector2.ZERO)
		$Teleportation/teleportation10/TeleportSound.play
	elif body is CharacterBody2D:
		print("Character Body Entered Teleportation!")
		body.global_position = $Teleportation/teleportation10.global_position + Vector2(40, 0)
		$Teleportation/teleportation9/TeleportSound.play()
		
		
func _on_teleportation_10_body_entered(body):
	if body is RigidBody2D:
		print("Rigid Body Entered Teleportation!")
		body.set_deferred("global_position", $Teleportation/teleportation9.global_position + Vector2(50, 0))
		body.set_deferred("linear_velocity", Vector2.ZERO)
		$Teleportation/teleportation9/TeleportSound.play
	elif body is CharacterBody2D:
		print("Character Body Entered Teleportation!")
		body.global_position = $Teleportation/teleportation9.global_position + Vector2(40, 0)
		$Teleportation/teleportation9/TeleportSound.play()
		


func _on_teleportation_11_body_entered(body):
	if body is RigidBody2D:
		print("Rigid Body Entered Teleportation!")
		body.set_deferred("global_position", $Teleportation/teleportation12.global_position + Vector2(50, 0))
		body.set_deferred("linear_velocity", Vector2.ZERO)
		$Teleportation/teleportation12/TeleportSound.play
	elif body is CharacterBody2D:
		print("Character Body Entered Teleportation!")
		body.global_position = $Teleportation/teleportation12.global_position + Vector2(40, 0)
		$Teleportation/teleportation12/TeleportSound.play()
		

func _on_teleportation_12_body_entered(body):
	if body is RigidBody2D:
		print("Rigid Body Entered Teleportation!")
		body.set_deferred("global_position", $Teleportation/teleportation11.global_position + Vector2(50, 0))
		body.set_deferred("linear_velocity", Vector2.ZERO)
		$Teleportation/teleportation11/TeleportSound.play
	elif body is CharacterBody2D:
		print("Character Body Entered Teleportation!")
		body.global_position = $Teleportation/teleportation11.global_position + Vector2(40, 0)
		$Teleportation/teleportation11/TeleportSound.play()
		
		
#<--- teleportation related code--->



#<---- RPC Calls Over Network for Door ---->
@rpc("any_peer", "call_local") func activate_door(door_number):
	var door_key = "door{0}".format([door_number])
	_door_states[door_key] = true
	$DoorNodes/DoorAnimation.play(door_key)
	get_node("DoorNodes/Door{0}Trigger".format([door_number])).visible = false
