extends Node

# Constantes para botones específicos
const JOY_L_SHOULDER = JOY_BUTTON_LEFT_SHOULDER
const JOY_R_SHOULDER = JOY_BUTTON_RIGHT_SHOULDER
# Constantes para los ejes de los triggers
const JOY_AXIS_R_TRIGGER = JOY_AXIS_TRIGGER_RIGHT  # ZR en Switch, R2 en PlayStation
const JOY_AXIS_L_TRIGGER = JOY_AXIS_TRIGGER_LEFT   # ZL en Switch, L2 en PlayStation

# Mapeo de teclas para teclado
const KEYBOARD_MAPPING = {
	"up": KEY_W,
	"down": KEY_S,
	"left": KEY_A,
	"right": KEY_D,
	"jump": KEY_SPACE,
	"attack": KEY_F,
	"interact": KEY_E,
	"sprint": KEY_SHIFT,
	"walking_mode": KEY_CTRL  # Tecla para cambiar entre modo caminar/correr
}

# Mapeo de botones para joystick (compatible con múltiples controles)
const JOYPAD_MAPPING = {
	"jump": JOY_BUTTON_A,     # Botón A en Xbox, B en Nintendo Switch
	"attack": JOY_BUTTON_X,   # Botón X en Xbox, Y en Nintendo Switch
	"interact": JOY_BUTTON_B, # Botón B en Xbox, A en Nintendo Switch
	"pause": JOY_BUTTON_START,
	# Sprint ya no se mapea aquí como botón, ahora es un eje
}

# Mapeo de ejes analógicos
const JOYPAD_AXIS_MAPPING = {
	"sprint": JOY_AXIS_R_TRIGGER,  # ZR en Switch, R2 en PlayStation
	"secondary": JOY_AXIS_L_TRIGGER # ZL en Switch, L2 en PlayStation
}

# Umbral para considerar un trigger presionado (valor entre 0 y 1)
const TRIGGER_THRESHOLD = 0.5

# Mapeo para Nintendo Switch (para referencia)
const SWITCH_MAPPING = {
	"jump": JOY_BUTTON_B,     # B en Nintendo Switch (equivale a A en Xbox)
	"attack": JOY_BUTTON_Y,   # Y en Nintendo Switch (equivale a X en Xbox)
	"interact": JOY_BUTTON_A, # A en Nintendo Switch (equivale a B en Xbox)
	"special": JOY_BUTTON_X   # X en Nintendo Switch (equivale a Y en Xbox)
}

# Configuración de sensibilidad
@export_group("Keyboard Settings")
@export var mouse_sensitivity_horizontal := 0.15
@export var mouse_sensitivity_vertical := 0.15

@export_group("Control Settings")
@export var controller_run_threshold := 0.6  # Umbral para activar el correr con stick
@export var controller_sensitivity_horizontal := 0.08
@export var controller_sensitivity_vertical := -0.08

@export_group("debug")
@export var debug_input := false

var Player1 : PlayerInput = null
var Player2 : PlayerInput = null
var assigning := false
var current_assignment := 0
var keyboard_assigned := false
var mouse_captured := false
var mouse_movement := Vector2.ZERO
var walking_mode := false  # Variable global para el modo caminar

func _ready():
	# Detectar dispositivos al inicio
	print("==== GAME INPUT MANAGER INICIADO ====")
	print("Dispositivos conectados:")
	for device in Input.get_connected_joypads():
		print("  - Dispositivo ID: ", device, " Nombre: ", Input.get_joy_name(device))
		# Detectar tipo de control (especialmente para Switch)
		_detect_controller_type(device)
	
	# Conectar señal para detectar conexión/desconexión de dispositivos
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	
	# Iniciar el proceso de asignación
	reassign()

# Detectar tipo de control y mostrar info
func _detect_controller_type(device_id: int):
	var device_name = Input.get_joy_name(device_id).to_lower()
	print("  - Verificando dispositivo:", device_name)
	
	if "nintendo" in device_name or "switch" in device_name:
		print("  - Detectado control de Nintendo Switch para dispositivo ID:", device_id)

func _on_joy_connection_changed(device_id: int, connected: bool):
	if connected:
		print("Dispositivo conectado - ID:", device_id, " Nombre:", Input.get_joy_name(device_id))
	else:
		print("Dispositivo desconectado - ID:", device_id)
		# Si un jugador estaba usando este dispositivo, reasignar
		if (Player1 and Player1.device_id == device_id) or (Player2 and Player2.device_id == device_id):
			print("Un jugador estaba usando este dispositivo. Reasignando...")
			reassign()

func reassign():
	Player1 = null
	Player2 = null
	assigning = true
	current_assignment = 1
	keyboard_assigned = false
	print("===== ASIGNACIÓN DE CONTROLES =====")
	print("Jugador 1: Presiona Q+E (teclado) o L+R (mando)")
	get_tree().paused = true

func _process(_delta):
	if assigning:
		# Comprobar asignación por teclado (Q+E)
		if Input.is_key_pressed(KEY_Q) and Input.is_key_pressed(KEY_E) and not keyboard_assigned:
			assign_keyboard()
		
		# Comprobar asignación por joypad (L+R)
		for device_id in Input.get_connected_joypads():
			if Input.is_joy_button_pressed(device_id, JOY_L_SHOULDER) and Input.is_joy_button_pressed(device_id, JOY_R_SHOULDER):
				assign_joypad(device_id)
	else:
		# Verificar toggle de captura de ratón con ESC
		if Input.is_action_just_pressed("ui_cancel"):
			_toggle_mouse_capture()
			
		# Verificar cambio de modo caminar/correr
		_check_walking_mode_toggle()
			
		# Modo de juego - Debug de inputs
		if debug_input:
			_debug_inputs()
			
		# Resetear el movimiento del ratón cada frame para evitar acumulación
		mouse_movement = Vector2.ZERO

# Función para comprobar cambio del modo caminar
func _check_walking_mode_toggle():
	# Comprobar si algún jugador presiona la tecla de modo caminar
	if (Player1 and Player1.is_button_just_pressed("walking_mode")) or \
	   (Player2 and Player2.is_button_just_pressed("walking_mode")):
		walking_mode = !walking_mode
		print("Modo caminar: ", "ACTIVADO" if walking_mode else "DESACTIVADO")

# Función para depurar inputs de ambos jugadores
func _debug_inputs():
	if Player1:
		var dir = Player1.get_direction()
		if dir.length() > 0.1:
			print("Jugador 1 [", Player1.type, " ID:", Player1.device_id, "] - Dir:", dir)
		
		var cam_dir = Player1.get_camera_direction()
		if cam_dir.length() > 0.1:
			print("Jugador 1 [", Player1.type, " ID:", Player1.device_id, "] - Cámara:", cam_dir)
		
		# Debug de botones
		for action in JOYPAD_MAPPING:
			if Player1.is_button_just_pressed(action):
				print("Jugador 1 [", Player1.type, " ID:", Player1.device_id, "] - Acción:", action)
		
		# Debug de ejes analógicos (triggers)
		for action in JOYPAD_AXIS_MAPPING:
			if Player1.is_axis_active(action):
				print("Jugador 1 [", Player1.type, " ID:", Player1.device_id, "] - Acción:", action, " - Valor:", Player1.get_axis_value(action))
				
		# Debug de valores RAW de los ejes (para verificar sensibilidad)
		if Player1.type == "joypad":
			var raw_x = Input.get_joy_axis(Player1.device_id, JOY_AXIS_LEFT_X)
			var raw_y = Input.get_joy_axis(Player1.device_id, JOY_AXIS_LEFT_Y)
			if abs(raw_x) > 0.05 or abs(raw_y) > 0.05:
				print("Jugador 1 - RAW joystick:", Vector2(raw_x, raw_y))
				
			# Debug de valores de los triggers
			var rt_value = Input.get_joy_axis(Player1.device_id, JOY_AXIS_R_TRIGGER)
			var lt_value = Input.get_joy_axis(Player1.device_id, JOY_AXIS_L_TRIGGER)
			if rt_value > 0.05:
				print("Jugador 1 - Trigger derecho (ZR/R2):", rt_value)
			if lt_value > 0.05:
				print("Jugador 1 - Trigger izquierdo (ZL/L2):", lt_value)
	
	if Player2:
		var dir = Player2.get_direction()
		if dir.length() > 0.1:
			print("Jugador 2 [", Player2.type, " ID:", Player2.device_id, "] - Dir:", dir)
		
		var cam_dir = Player2.get_camera_direction()
		if cam_dir.length() > 0.1:
			print("Jugador 2 [", Player2.type, " ID:", Player2.device_id, "] - Cámara:", cam_dir)
		
		# Debug de botones
		for action in JOYPAD_MAPPING:
			if Player2.is_button_just_pressed(action):
				print("Jugador 2 [", Player2.type, " ID:", Player2.device_id, "] - Acción:", action)
		
		# Debug de ejes analógicos (triggers)
		for action in JOYPAD_AXIS_MAPPING:
			if Player2.is_axis_active(action):
				print("Jugador 2 [", Player2.type, " ID:", Player2.device_id, "] - Acción:", action, " - Valor:", Player2.get_axis_value(action))
				
		# Debug de valores RAW de los ejes (para verificar sensibilidad)
		if Player2.type == "joypad":
			var raw_x = Input.get_joy_axis(Player2.device_id, JOY_AXIS_LEFT_X)
			var raw_y = Input.get_joy_axis(Player2.device_id, JOY_AXIS_LEFT_Y)
			if abs(raw_x) > 0.05 or abs(raw_y) > 0.05:
				print("Jugador 2 - RAW joystick:", Vector2(raw_x, raw_y))
				
			# Debug de valores de los triggers
			var rt_value = Input.get_joy_axis(Player2.device_id, JOY_AXIS_R_TRIGGER)
			var lt_value = Input.get_joy_axis(Player2.device_id, JOY_AXIS_L_TRIGGER)
			if rt_value > 0.05:
				print("Jugador 2 - Trigger derecho (ZR/R2):", rt_value)
			if lt_value > 0.05:
				print("Jugador 2 - Trigger izquierdo (ZL/L2):", lt_value)

func assign_keyboard():
	if current_assignment == 1:
		Player1 = PlayerInput.new("keyboard", -1)
		Player1.set_run_threshold(controller_run_threshold) # Pasar el valor desde el manager
		keyboard_assigned = true
		print("Jugador 1 asignado al teclado")
		current_assignment = 2
		print("Jugador 2: Presiona Q+E (teclado) o L+R (mando)")
	elif current_assignment == 2 and not keyboard_assigned:
		Player2 = PlayerInput.new("keyboard", -1)
		Player2.set_run_threshold(controller_run_threshold) # Pasar el valor desde el manager
		keyboard_assigned = true
		print("Jugador 2 asignado al teclado")
		finish_assignment()

func assign_joypad(device_id: int):
	# Evitar asignar un dispositivo ya asignado
	if (Player1 and Player1.device_id == device_id) or (Player2 and Player2.device_id == device_id):
		print("Dispositivo ya asignado, ID:", device_id)
		return
	
	if current_assignment == 1:
		Player1 = PlayerInput.new("joypad", device_id)
		Player1.set_run_threshold(controller_run_threshold) # Pasar el valor desde el manager
		print("Jugador 1 asignado al control ID:", device_id, " (", Input.get_joy_name(device_id), ")")
		current_assignment = 2
		print("Jugador 2: Presiona Q+E (teclado) o L+R (mando)")
	elif current_assignment == 2:
		Player2 = PlayerInput.new("joypad", device_id)
		Player2.set_run_threshold(controller_run_threshold) # Pasar el valor desde el manager
		print("Jugador 2 asignado al control ID:", device_id, " (", Input.get_joy_name(device_id), ")")
		finish_assignment()

func finish_assignment():
	assigning = false
	get_tree().paused = false
	print("===== ASIGNACIÓN COMPLETADA =====")
	
	# Imprimir configuración final
	if Player1:
		print("Jugador 1:", Player1.type, "ID:", Player1.device_id)
		Player1.player_number = 1
		# Si el jugador 1 usa teclado, capturar el ratón
		if Player1.type == "keyboard":
			_capture_mouse()
	if Player2:
		print("Jugador 2:", Player2.type, "ID:", Player2.device_id)
		Player2.player_number = 2
		# Si el jugador 2 usa teclado y el jugador 1 no, capturar el ratón
		if Player2.type == "keyboard" and (Player1 == null or Player1.type != "keyboard"):
			_capture_mouse()
	
	# Asignar inputs a los nodos de jugador
	var player_nodes = get_tree().get_nodes_in_group("players")
	for player in player_nodes:
		if player.has_method("assign_input"):
			if player.jugador_id == 0 and Player1:
				player.assign_input(Player1)
				print("Input asignado al jugador 1 en el juego")
			elif player.jugador_id == 1 and Player2:
				player.assign_input(Player2)
				print("Input asignado al jugador 2 en el juego")

# Función para capturar el ratón
func _capture_mouse():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	mouse_captured = true
	print("Ratón capturado para control de cámara")

# Función para alternar la captura del ratón
func _toggle_mouse_capture():
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		mouse_captured = false
		print("Ratón liberado - Juego pausado")
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		mouse_captured = true
		print("Ratón capturado - Juego reanudado")

# Función para comprobar si está en modo caminar
func is_walking_mode() -> bool:
	return walking_mode

# Clase para gestionar entrada de jugadores
class PlayerInput:
	var type: String
	var device_id: int
	var player_number := 0  # 1 para jugador 1, 2 para jugador 2
	var previous_buttons := {}
	var previous_axes := {}
	var deadzone := 0.2  # Valor configurable para la zona muerta
	var stick_magnitude := 0.0  # Guarda la intensidad del stick para comprobar corriendo
	var run_threshold := 0.6  # Valor por defecto, se actualizará desde el manager
	
	func _init(input_type: String, id: int):
		type = input_type
		device_id = id
	
	# Setter para el umbral de carrera
	func set_run_threshold(threshold: float) -> void:
		run_threshold = threshold
	
	# Obtener vector de dirección del movimiento (joystick izquierdo/WASD)
	func get_direction() -> Vector2:
		var direction = Vector2.ZERO
		
		if type == "keyboard":
			# Movimiento por teclado
			if Input.is_key_pressed(KEYBOARD_MAPPING["right"]):
				direction.x += 1
			if Input.is_key_pressed(KEYBOARD_MAPPING["left"]):
				direction.x -= 1
			if Input.is_key_pressed(KEYBOARD_MAPPING["down"]):
				direction.y += 1
			if Input.is_key_pressed(KEYBOARD_MAPPING["up"]):
				direction.y -= 1
			
			# Para teclado, la magnitud siempre es 0 o 1
			stick_magnitude = direction.length()
		
		elif type == "joypad":
			# OPTIMIZACIÓN: Usar un enfoque similar a Input.get_vector para mayor precisión
			var raw_input = Vector2(
				Input.get_joy_axis(device_id, JOY_AXIS_LEFT_X),
				Input.get_joy_axis(device_id, JOY_AXIS_LEFT_Y)
			)
			
			# Guardar la magnitud del stick (sin aplicar deadzone) para verificar corriendo
			stick_magnitude = raw_input.length()
			
			# Aplicar deadzone radial (como lo hace Input.get_vector)
			if stick_magnitude > deadzone:
				# Normalizar y ajustar la magnitud considerando la deadzone
				direction = raw_input * ((stick_magnitude - deadzone) / (1.0 - deadzone)) / stick_magnitude
			else:
				stick_magnitude = 0.0
			
			# D-pad digital (valores exactos)
			if Input.is_joy_button_pressed(device_id, JOY_BUTTON_DPAD_RIGHT):
				direction.x = 1.0
				stick_magnitude = 1.0
			elif Input.is_joy_button_pressed(device_id, JOY_BUTTON_DPAD_LEFT):
				direction.x = -1.0
				stick_magnitude = 1.0
			
			if Input.is_joy_button_pressed(device_id, JOY_BUTTON_DPAD_DOWN):
				direction.y = 1.0
				stick_magnitude = 1.0
			elif Input.is_joy_button_pressed(device_id, JOY_BUTTON_DPAD_UP):
				direction.y = -1.0
				stick_magnitude = 1.0
		
		# Normalizar si es necesario
		if direction.length() > 1.0:
			direction = direction.normalized()
			
		return direction
	
	# Obtener vector de dirección de la cámara (joystick derecho/Mouse)
	func get_camera_direction() -> Vector2:
		var direction = Vector2.ZERO
		
		if type == "keyboard":
			# Si el ratón está capturado, usar el movimiento del ratón
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				direction = Input.get_last_mouse_velocity() * -0.01
			else:
				# Usando flechas como respaldo si el ratón no está capturado
				if Input.is_key_pressed(KEY_RIGHT):
					direction.x += 1
				if Input.is_key_pressed(KEY_LEFT):
					direction.x -= 1
				if Input.is_key_pressed(KEY_DOWN):
					direction.y += 1
				if Input.is_key_pressed(KEY_UP):
					direction.y -= 1
		
		elif type == "joypad":
			# OPTIMIZACIÓN: Mismo enfoque que en get_direction para mayor precisión
			var raw_input = Vector2(
				Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_X),
				Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_Y)
			)
			
			var input_length = raw_input.length()
			if input_length > deadzone:
				direction = raw_input * ((input_length - deadzone) / (1.0 - deadzone)) / input_length
		
		# Normalizar si es necesario
		if direction.length() > 1.0:
			direction = direction.normalized()
			
		return direction
	
	# Verificar si un botón está siendo presionado
	func is_button_pressed(action: String) -> bool:
		if type == "keyboard":
			if action in KEYBOARD_MAPPING:
				return Input.is_key_pressed(KEYBOARD_MAPPING[action])
		elif type == "joypad":
			# Para botones regulares
			if action in JOYPAD_MAPPING:
				return Input.is_joy_button_pressed(device_id, JOYPAD_MAPPING[action])
			# Para ejes analógicos (triggers)
			elif action in JOYPAD_AXIS_MAPPING:
				return Input.get_joy_axis(device_id, JOYPAD_AXIS_MAPPING[action]) > TRIGGER_THRESHOLD
		return false
	
	# Nueva función para verificar si un eje está activo
	func is_axis_active(action: String) -> bool:
		if type == "joypad" and action in JOYPAD_AXIS_MAPPING:
			return Input.get_joy_axis(device_id, JOYPAD_AXIS_MAPPING[action]) > TRIGGER_THRESHOLD
		return false
	
	# Nueva función para obtener el valor de un eje
	func get_axis_value(action: String) -> float:
		if type == "joypad" and action in JOYPAD_AXIS_MAPPING:
			return Input.get_joy_axis(device_id, JOYPAD_AXIS_MAPPING[action])
		return 0.0
		
	# Verificar si el stick está lo suficientemente inclinado para correr
	func should_run() -> bool:
		# Si el modo caminar está activado, nunca correr
		if GameInputManager.walking_mode && type == "keyboard":
			return false
			
		# De lo contrario, verificar la inclinación del stick usando el umbral definido
		return stick_magnitude >= run_threshold
	
	# Verificar si un botón acaba de ser presionado (solo un frame)
	func is_button_just_pressed(action: String) -> bool:
		var current_pressed = is_button_pressed(action)
		var key = action
		
		if not key in previous_buttons:
			previous_buttons[key] = false
		
		var just_pressed = current_pressed and not previous_buttons[key]
		previous_buttons[key] = current_pressed
		
		return just_pressed
	
	# Para compatibilidad con el código existente
	func is_action_pressed(action: String) -> bool:
		return is_button_pressed(action)
	
	func is_action_just_pressed(action: String) -> bool:
		return is_button_just_pressed(action)
	
	func direction() -> Vector2:
		return get_direction()
