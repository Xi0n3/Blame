extends Node3D
@onready var camera_3d = $SpringArm3D/Camera3D
@onready var player = $".."
@onready var visuals = $"../visuals"

@export_group("Settings")
@export var default_fov = 75
@export var sprint_fov = 90
@export var transition_speed = 5.0
@export var max_rotation_y = 45
@export var min_rotation_y = -70

var input := Vector3.ZERO

func _ready():
	player.sprinting_changed.connect(_on_sprinting_changed)

func _physics_process(delta):
	control_input()
	
	player.rotate_y(input.x) # Voltea al player con la camara en el eje Y
	visuals.rotate_y(-input.x) # Evita que el modelo del player se gira con la camara
	
	# La camara se puede mover en el eje de rotacion x si...
	if ((rad_to_deg(rotation.x) < max_rotation_y || input.y < 0) && # Puede moverse para abajo
	   (rad_to_deg(rotation.x) > min_rotation_y || input.y > 0)):   # Puede moverse para arriba
		rotate_x(input.y)
		
	input.x = 0; input.y = 0
	
func control_input():
	var cam_input_dir = player.input_ref.get_camera_direction()
	if cam_input_dir:
		if player.input_ref.type == "joypad":
			# Usar las sensibilidades del InputManager para controlador
			input.x = -cam_input_dir.x * GameInputManager.controller_sensitivity_horizontal
			input.y = cam_input_dir.y * GameInputManager.controller_sensitivity_vertical
		else:
			# Para mouse se maneja en la función _input
			pass
	
func _input(event):
	# Mouse input values con sensibilidad desde GameInputManager
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		input.x = -deg_to_rad(event.relative.x * GameInputManager.mouse_sensitivity_horizontal)
		input.y = -deg_to_rad(event.relative.y * GameInputManager.mouse_sensitivity_vertical)
		
func _on_sprinting_changed(is_sprinting):
	var target_fov = sprint_fov if is_sprinting else default_fov
	create_tween().tween_property(camera_3d, "fov", target_fov, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
