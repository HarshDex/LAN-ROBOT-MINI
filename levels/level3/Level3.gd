extends Node2D

@export var spawn_points: Array[Vector2] = [Vector2(3488 , 400), Vector2(3889, 666)]
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
}




#<--- Door Related Code ---->



#<---for laser---->
var laser1_interaction = false
var laser2_interaction = false
var laser3_interaction = false
var laser4_interaction = false
var laser5_interaction = false
#<---for laser---->

#<---for platform--->
var platform_interaction1 = false
var platform_interaction2 = false
var platform_interaction3 = false
var platform_interaction4 = false
var platform_interaction5 = false
var platform_interaction6 = false
var platform_interaction7 = false
var platform_interaction8 = false


var _upDown1: bool = true;
@export var upDown1: bool:
	get:
		return _upDown1
	set(value):
		if _upDown1 != value:
			_upDown1 = value
			if multiplayer.is_server():
				rpc("sync_updown1", _upDown1)


var _upDown2 : bool = false
@export var upDown2: bool:
	get:
		return _upDown2
	set(value):
		if _upDown2 != value:
			_upDown2 = value
			if multiplayer.is_server():
				rpc("sync_updown2", _upDown2)

var _upDown3 = false
@export var upDown3: bool:
	get:
		return _upDown3
	set(value):
		if _upDown3 != value:
			_upDown3 = value
			if multiplayer.is_server():
				rpc("sync_updown3", _upDown3)

var _upDown4 = false
@export var upDown4: bool:
	get:
		return _upDown4
	set(value):
		if _upDown4 != value:
			_upDown4 = value
			if multiplayer.is_server():
				rpc("sync_updown4", _upDown4)

var _upDown5 = false
@export var upDown5: bool:
	get:
		return _upDown5
	set(value):
		if _upDown5 != value:
			_upDown5 = value
			if multiplayer.is_server():
				rpc("sync_updown5", _upDown5)

var _upDown6 = false
@export var upDown6: bool:
	get:
		return _upDown6
	set(value):
		if _upDown6 != value:
			_upDown6 = value
			if multiplayer.is_server():
				rpc("sync_updown6", _upDown6)

var _upDown7 = true
@export var upDown7: bool:
	get:
		return _upDown7
	set(value):
		if _upDown7 != value:
			_upDown7 = value
			if multiplayer.is_server():
				rpc("sync_updown7", _upDown7)

var _upDown8 = true
@export var upDown8: bool:
	get:
		return _upDown8
	set(value):
		if _upDown8 != value:
			_upDown8 = value
			if multiplayer.is_server():
				rpc("sync_updown7", _upDown8)

#<---for platform--->



#<---- RPC CALLS --->

#<---- RPC Calls Over Network for Door ---->
@rpc("any_peer", "call_local") func activate_door(door_number):
	var door_key = "door{0}".format([door_number])
	_door_states[door_key] = true
	$DoorNodes/DoorAnimation.play(door_key)
	get_node("DoorNodes/Door{0}Trigger".format([door_number])).visible = false

# New: RPC function to sync door state
@rpc("any_peer", "call_local") func sync_door_state(door_key, state):
	_door_states[door_key] = state

#<---- RPC Calls Over Network for Door ---->


#<---- RPC Calls Over Network for Moving Platform ---->


#for platform 1
@rpc("any_peer", "call_local") func play_platform_animation1():
	if upDown1:
		print("animation played")
		$MovingPlatform/MovingPlatformAnimation.play("platform1up")
	else:
		print("down animation player")
		$MovingPlatform/MovingPlatformAnimation.play("platform1down")
	upDown1 = !upDown1

# New: RPC function to sync upDown1
@rpc("any_peer", "call_local") func sync_updown1(value):
	_upDown1 = value


# for platform 2
@rpc("any_peer", "call_local") func play_platform_animation2():
	if upDown2:
		print("animation played")
		$MovingPlatform/MovingPlatformAnimation.play("platform2up")
	else:
		print("down animation player")
		$MovingPlatform/MovingPlatformAnimation.play("platform2down")
	upDown2 = !upDown2

# New: RPC function to sync upDown2
@rpc("any_peer", "call_local") func sync_updown2(value):
	_upDown2 = value


# for platform 3
@rpc("any_peer", "call_local") func play_platform_animation3():
	if upDown3:
		print("animation played")
		$MovingPlatform/MovingPlatformAnimation.play("platform3up")
	else:
		print("down animation player")
		$MovingPlatform/MovingPlatformAnimation.play("platform3down")
	upDown3 = !upDown3

# New: RPC function to sync upDown3
@rpc("any_peer", "call_local") func sync_updown3(value):
	_upDown3 = value


# for platform 4
@rpc("any_peer", "call_local") func play_platform_animation4():
	if upDown4:
		print("animation played")
		$MovingPlatform/MovingPlatformAnimation.play("platform4up")
	else:
		print("down animation player")
		$MovingPlatform/MovingPlatformAnimation.play("platform4down")
	upDown4 = !upDown4

# New: RPC function to sync upDown3
@rpc("any_peer", "call_local") func sync_updown4(value):
	_upDown4 = value
	
# for platform 5
@rpc("any_peer", "call_local") func play_platform_animation5():
	if upDown5:
		print("animation played")
		$MovingPlatform/MovingPlatformAnimation.play("platform5up")
	else:
		print("down animation player")
		$MovingPlatform/MovingPlatformAnimation.play("platform5down")
	upDown5 = !upDown5

# New: RPC function to sync upDown5
@rpc("any_peer", "call_local") func sync_updown5(value):
	_upDown5 = value
	
# for platform 6
@rpc("any_peer", "call_local") func play_platform_animation6():
	if upDown6:
		print("animation played")
		$MovingPlatform/MovingPlatformAnimation.play("platform6up")
	else:
		print("down animation player")
		$MovingPlatform/MovingPlatformAnimation.play("platform6down")
	upDown6 = !upDown6

# New: RPC function to sync upDown6
@rpc("any_peer", "call_local") func sync_updown6(value):
	_upDown6 = value
	
# for platform 7
@rpc("any_peer", "call_local") func play_platform_animation7():
	if upDown7:
		print("animation played")
		$MovingPlatform/MovingPlatformAnimation.play("platform7up")
	else:
		print("down animation player")
		$MovingPlatform/MovingPlatformAnimation.play("platform7down")
	upDown7= !upDown7

# New: RPC function to sync upDown7
@rpc("any_peer", "call_local") func sync_updown7(value):
	_upDown7 = value
	
# for platform 8
@rpc("any_peer", "call_local") func play_platform_animation8():
	if upDown8:
		print("animation played")
		$MovingPlatform/MovingPlatformAnimation.play("platform8up")
	else:
		print("down animation player")
		$MovingPlatform/MovingPlatformAnimation.play("platform7down")
	upDown8= !upDown8

# New: RPC function to sync upDown7
@rpc("any_peer", "call_local") func sync_updown8(value):
	_upDown8 = value

#<---- RPC Calls Over Network for Moving Platfomr ---->


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

	#<----Platform related----->
	if Input.is_action_just_pressed("interact") and platform_interaction1 == true:
		rpc("play_platform_animation1")  # Modified: Call RPC for all peers
	
		
	if Input.is_action_just_pressed("interact") and platform_interaction2 == true:
		rpc("play_platform_animation2")  # Modified: Call RPC for all peers
	
	if Input.is_action_just_pressed("interact") and platform_interaction3 == true:
		rpc("play_platform_animation3")
	
	if Input.is_action_just_pressed("interact") and platform_interaction4 == true:
		rpc("play_platform_animation4")
			
	if Input.is_action_just_pressed("interact") and platform_interaction5 == true:
		rpc("play_platform_animation5")
			
	if Input.is_action_just_pressed("interact") and platform_interaction6 == true:
		rpc("play_platform_animation6")
			
	if Input.is_action_just_pressed("interact") and platform_interaction7 == true:
		rpc("play_platform_animation7")
	#<----platform related----->
	
	
	
	
#<--- Door Related Code ---->


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
	

func _on_door_5_trigger_body_entered(body):
	if body.is_in_group("player"):
		$DoorNodes/Door5Trigger/Label.visible = true
		door5_interaction = true
	
func _on_door_5_trigger_body_exited(body):
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
	

func _on_door_10_trigger_body_entered(body):
	if body.is_in_group("player"):
		$DoorNodes/Door10Trigger/Label.visible = true
		door10_interaction = true
		

func _on_door_10_trigger_body_exited(body):
	$DoorNodes/Door10Trigger/Label.visible = false
	door10_interaction = false

#<--- Door Related Code ---->




#<--- DoorWeight Related Code ---->		

func _on_door_3_trigger_body_entered(body):
	if body.is_in_group("player") or body.is_in_group("boxes"):
		print("player entered in tigger")
		$DoorNodes/DoorAnimation.play("door3")


func _on_door_3_trigger_body_exited(body):
	$DoorNodes/DoorAnimation.play("door3_closed")
	
	
func _on_door_4_trigger_body_entered(body):
	if body.is_in_group("player") or body.is_in_group("boxes"):
		print("player entered in tigger")
		$DoorNodes/DoorAnimation.play("door4")

func _on_door_4_trigger_body_exited(body):
	$DoorNodes/DoorAnimation.play("door4_closed")
	
func _on_door_8_trigger_body_entered(body):
	if body.is_in_group("player") or body.is_in_group("boxes"):
		print("player entered in tigger")
		$DoorNodes/DoorAnimation.play("door8")
		

func _on_door_8_trigger_body_exited(body):
	$DoorNodes/DoorAnimation.play("door8_closed")
	
func _on_door_9_trigger_body_entered(body):
	if body.is_in_group("player") or body.is_in_group("boxes"):
		print("player entered in tigger")
		$DoorNodes/DoorAnimation.play("door9")
		

func _on_door_9_trigger_body_exited(body):
	$DoorNodes/DoorAnimation.play("door9_closed")

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
	

#<--- Laser Trigger related code ---->



#<--- Laser Weight Trigger related code ---->

func _on_laser_1_trigger_weight_body_entered(body):
	print('laser off')
	if body.is_in_group("player") or body.is_in_group("boxes"):
		$LaserTriggers/Laser.visible = false


func _on_laser_1_trigger_weight_body_exited(body):
	print("laser on");
	$LaserTriggers/Laser.visible = true


func _on_laser_2_trigger_weight_body_entered(body):
	if body.is_in_group("player") or body.is_in_group("boxes"):
		laser2_interaction = false
		$LaserTriggers/Laser2.visible = false


func _on_laser_2_trigger_weight_body_exited(body):
	$LaserTriggers/Laser2.visible = true
	

func _on_laser_3_trigger_weight_body_entered(body):
	if body.is_in_group("player") or body.is_in_group("boxes"):
		laser3_interaction = false
		$LaserTriggers/Laser3.visible = false
		
func _on_laser_3_trigger_weight_body_exited(body):
	$LaserTriggers/Laser3.visible = true

func _on_laser_4_trigger_weight_body_entered(body):
	if body.is_in_group("player") or body.is_in_group("boxes"):
		laser4_interaction = false
		$LaserTriggers/Laser4.visible = false


func _on_laser_4_trigger_weight_body_exited(body):
	$LaserTriggers/Laser4.visible = true

func _on_laser_5_trigger_weight_body_entered(body):
	if body.is_in_group("player") or body.is_in_group("boxes"):
		laser5_interaction = false
		$LaserTriggers/Laser5.visible = false

func _on_laser_5_trigger_weight_body_exited(body):
	$LaserTriggers/Laser5.visible = true


#<--- Laser Weight Trigger related code ---->

#<--- teleportation related code--->
func _on_teleportation_body_entered(body):
	if body is RigidBody2D:
		body.set_deferred("global_position", $Teleportation/teleportation2.global_position + Vector2(50, 0))
		body.set_deferred("linear_velocity", Vector2.ZERO)
		$Teleportation/teleportation/TeleportSound.play()
	elif body is CharacterBody2D:
		body.global_position = $Teleportation/teleportation2.global_position + Vector2(40, 0)
		$Teleportation/teleportation/TeleportSound.play()


func _on_teleportation_2_body_entered(body):
	if body is RigidBody2D:
		body.set_deferred("global_position", $Teleportation/teleportation.global_position + Vector2(50, 0))
		body.set_deferred("linear_velocity", Vector2.ZERO)
		$Teleportation/teleportation2/TeleportSound.play()
	elif body is CharacterBody2D:
		body.global_position = $Teleportation/teleportation.global_position + Vector2(40, 0)
		$Teleportation/teleportation2/TeleportSound.play()

#<--- teleportation related code--->


#<----platform trigger related code--->



func _on_platform_trigger_body_entered(body):
	if body.is_in_group("player"):
		#print("reached here")
		$MovingPlatform/MovingPlatform/platformTrigger/Label.visible = true
		platform_interaction1 = true

func _on_platform_trigger_body_exited(body):
	$MovingPlatform/MovingPlatform/platformTrigger/Label.visible = false
	platform_interaction1 = false
	


func _on_platform_trigger2_body_entered(body):
	if body.is_in_group("player"):
		print("reached here")
		$MovingPlatform/Platform2/platformTrigger/Label.visible = true
		platform_interaction2 = true

func _on_platform_trigger2_body_exited(body):
	$MovingPlatform/Platform2/platformTrigger/Label.visible = false
	platform_interaction2 = false
	

func _on_platform_trigger3_body_entered(body):
	if body.is_in_group("player"):
		print("reached here")
		$MovingPlatform/Platform3/platformTrigger/Label.visible = true
		platform_interaction3 = true
		

func _on_platform_trigger3_body_exited(body):
	$MovingPlatform/Platform3/platformTrigger/Label.visible = false
	platform_interaction3 = false

func _on_platform_trigger4_body_entered(body):
	if body.is_in_group("player"):
		print("reached here")
		$MovingPlatform/Platform4/platformTrigger/Label.visible = true
		platform_interaction4 = true

func _on_platform_trigger4_body_exited(body):
	$MovingPlatform/Platform4/platformTrigger/Label.visible = false
	platform_interaction4 = false
	
func _on_platform_trigger5_body_entered(body):
	if body.is_in_group("player"):
		print("reached here")
		$MovingPlatform/Platform5/platformTrigger/Label.visible = true
		platform_interaction5 = true
		
func _on_platform_trigger5_body_exited(body):
	$MovingPlatform/Platform5/platformTrigger/Label.visible = false
	platform_interaction5 = false
	
func _on_platform_trigger6_body_entered(body):
	if body.is_in_group("player"):
		print("reached here")
		$MovingPlatform/Platform6/platformTrigger/Label.visible = true
		platform_interaction6 = true
		
func _on_platform_trigger6_body_exited(body):
	$MovingPlatform/Platform6/platformTrigger/Label.visible = false
	platform_interaction6 = false
	
func _on_platform_trigger7_body_entered(body):
	if body.is_in_group("player"):
		print("reached here")
		$MovingPlatform/Platform7/platformTrigger/Label.visible = true
		platform_interaction7 = true
		
func _on_platform_trigger7_body_exited(body):
	$MovingPlatform/Platform7/platformTrigger/Label.visible = false
	platform_interaction7 = false
	
#<----platform trigger related code--->






