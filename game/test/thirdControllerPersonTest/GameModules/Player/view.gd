extends Node3D
@onready var camera_3d = $SpringArm3D/Camera3D
@onready var player = $".."
@onready var visuals = $"../visuals"
@export_group("Control Settings")
@export var controller_camera_sens_horizontal = 0.08
@export var controller_camera_sens_vertical = -0.08
@export_group("Mouse Settings")
@export var mouse_camera_sens_horizontal = 0.15
@export var mouse_camera_sens_vertical = 0.15
@export_group("Settings")
@export var default_fov = 75
@export var sprint_fov = 90
@export var transition_speed = 5.0
@export var max_rotation_y = 45
@export var min_rotation_y = -70


var input := Vector3.ZERO

#func _ready():
	#player.sprinting_changed.connect(_on_sprinting_changed)

func _physics_process(delta):
	control_input()
	
	player.rotate_y(input.x) #voltea al player y con la camara en el eje Y
	visuals.rotate_y(-input.x) #Evita que el modelo del player se gira con la camara (así la direccion siempre coincide donde mire la camara)
	#
	#print("deg: "+ str(rad_to_deg(rotation.x)))
	#print("radianes: " + str(deg_to_rad((rotation.x))))
	#La camara se puede mover en el eje de rotacion x si...
	#recordar pasar rotationa de radianes a grados para que sea más entendible
	if ((rad_to_deg(rotation.x) < max_rotation_y || input.y<0) && #puede moverse para abajo
	(rad_to_deg(rotation.x) > min_rotation_y || input.y>0)): #puede moverse para arriba
		rotate_x(input.y)
		
	input.x=0; input.y=0
	

func control_input():
	var cam_input_dir = Input.get_vector("camera_right", "camera_left", "camera_up", "camera_down")
	if cam_input_dir:
		input.x = cam_input_dir.x*controller_camera_sens_horizontal
		input.y = cam_input_dir.y*controller_camera_sens_vertical
	
func _input(event):
	#mouse input values
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		input.x = -deg_to_rad(event.relative.x*mouse_camera_sens_horizontal)
		input.y = -deg_to_rad(event.relative.y*mouse_camera_sens_vertical)
		
func _on_sprinting_changed(is_sprinting):
	var target_fov = sprint_fov if is_sprinting else default_fov
	create_tween().tween_property(camera_3d, "fov", target_fov, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
