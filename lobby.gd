extends Control

var peer = ENetMultiplayerPeer.new()
var max_players = 2

@onready var address_line_edit = $HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/BootOptions/ConnectAddress
@onready var port_line_edit = $HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/BootOptions/PortNumber
@onready var error_dialog = $ErrorWindow

var ip_address
var level_instance = "res://levels/level2/Level2.tscn"

func _ready():
	var get_ip_address = IP.get_local_addresses()
	ip_address = get_local_ip_address(get_ip_address)
	address_line_edit.text = ip_address

func _on_host_pressed():
	var port
	var port_text = port_line_edit.text.strip_edges()
	#if port_text.is_empty():
		#show_error_dialog("Please enter a port number.")
		#return
#
	#var address_text = address_line_edit.text.strip_edges()
	#if address_text.is_empty():
		#show_error_dialog("Please enter an IP address or hostname.")
		#return
	#
	#
	
	if port_text == "Team A":
		port = 4200
	elif port_text == "Team B":
		port = 4201
	elif port_text == "Team C":
		port = 4202
	elif port_text == "Team D":
		port = 4203
	elif port_text == "Team E":
		port = 4204

	peer.create_server(port, max_players)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_player_connected)
	get_tree().change_scene_to_file(level_instance)

func _on_join_pressed():
	var port
	var address_text = address_line_edit.text.strip_edges()
	if address_text.is_empty():
		show_error_dialog("Please enter an IP address or hostname.")
		return

	var port_text = port_line_edit.text.strip_edges()
	#if port_text.is_empty():
		#show_error_dialog("Please enter a port number.")
		#return
		
		
	if port_text == "Team A":
		port = 4200
	elif port_text == "Team B":
		port = 4201
	elif port_text == "Team C":
		port = 4202
	elif port_text == "Team D":
		port = 4203
	elif port_text == "Team E":
		port = 4204

	#if port < 1024 or port > 65535:
		#show_error_dialog("Invalid port number. Please enter a value between 1024 and 65535.")
		#return

	peer.create_client(address_text, port)
	multiplayer.multiplayer_peer = peer
	get_tree().change_scene_to_file(level_instance)

func _on_player_connected(peer_id):
	print("Player connected: ", peer_id)

	if multiplayer.get_peers().size() >= max_players:
		print("Maximum player limit reached. Cannot add more players.")
		return

	# Check if the player is already spawned
	var existing_player = get_node_or_null("player_" + str(peer_id))
	if existing_player:
		print("Player with peer ID ", peer_id, " already exists. Skipping spawn.")
		return

	if multiplayer.is_server():
		_spawn_player(peer_id)

func _spawn_player(peer_id):
	var spawn_point = get_spawn_point(peer_id)
	rpc("_spawn_player_remotely", peer_id, spawn_point)

func get_spawn_point(peer_id):
	var peer_index = peer_id - 1
	return level_instance.spawn_points[peer_index % level_instance.spawn_points.size()]

func get_local_ip_address(ip_addresses):
	for ip in ip_addresses:
		if ip.begins_with("192.168.") or ip.begins_with("10.") or ip.begins_with("172.16.") or ip.begins_with("172.17.") or ip.begins_with("172.18.") or ip.begins_with("172.19.") or ip.begins_with("172.20.") or ip.begins_with("172.21.") or ip.begins_with("172.22.") or ip.begins_with("172.23.") or ip.begins_with("172.24.") or ip.begins_with("172.25.") or ip.begins_with("172.26.") or ip.begins_with("172.27.") or ip.begins_with("172.28.") or ip.begins_with("172.29.") or ip.begins_with("172.30.") or ip.begins_with("172.31."):
			return ip
	return ""

func show_error_dialog(message):
	error_dialog.dialog_text = message
	error_dialog.popup_centered()
