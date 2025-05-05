extends Node

const JOY_L = 9
const JOY_R = 10


var player_inputs = {} # device_id o "keyboard" -> player_id
var current_assigning_player = 1

var keyboard_q_pressed = false
var keyboard_e_pressed = false
var joypad_r_pressed = {} # device_id -> bool
var joypad_l_pressed = {} # device_id -> bool

func _ready():
	print("Dispositivos conectados:")
	for device_id in Input.get_connected_joypads():
		print(" - Control ID:", device_id, "| Nombre:", Input.get_joy_name(device_id))
	print("Jugador 1: Presiona R+L en un control o Q+E en teclado para asignarte.")

func _input(event):
	if player_inputs.size() >= 2:
		_handle_gameplay_input(event)
		return

	# TECLADO
	if event is InputEventKey:
		if event.keycode == KEY_Q:
			keyboard_q_pressed = event.pressed
		elif event.keycode == KEY_E:
			keyboard_e_pressed = event.pressed

		if keyboard_q_pressed and keyboard_e_pressed and "keyboard" not in player_inputs:
			_assign_device_to_player("keyboard")

	# JOYPAD
	elif event is InputEventJoypadButton:
		var device = event.device
		if event.button_index == JOY_L:
			joypad_l_pressed[device] = event.pressed
		elif event.button_index == JOY_R:
			joypad_r_pressed[device] = event.pressed

		if joypad_l_pressed.get(device, false) and joypad_r_pressed.get(device, false) and device not in player_inputs:
			_assign_device_to_player(device)

func _assign_device_to_player(device):
	player_inputs[device] = current_assigning_player
	print("Asignado: Jugador %d -> %s" % [current_assigning_player, str(device)])
	current_assigning_player += 1

	if current_assigning_player <= 2:
		print("Jugador %d: Presiona R+L en un control o Q+E en teclado para asignarte." % current_assigning_player)
	else:
		print("¡Ambos jugadores asignados!")

func _handle_gameplay_input(event):
	var device = null
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		device = event.device
	elif event is InputEventKey or event is InputEventMouseButton or event is InputEventMouseMotion:
		device = "keyboard"

	if device in player_inputs:
		var player = player_inputs[device]

		if event is InputEventJoypadButton:
			print("Jugador", player, "| Control", device, "| Botón:", event.button_index)
		elif event is InputEventJoypadMotion:
			pass
			#print("Jugador", player, "| Control", device, "| Eje:", event.axis, "| Valor:", event.axis_value)
		elif event is InputEventKey:
			print("Jugador", player, "| Teclado | Tecla:", event.keycode)
		elif event is InputEventMouseButton:
			print("Jugador", player, "| Mouse | Botón:", event.button_index)
		elif event is InputEventMouseMotion:
			print("Jugador", player, "| Mouse movido | Pos:", event.position, "Vel:", event.velocity)
