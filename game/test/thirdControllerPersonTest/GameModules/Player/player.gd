extends CharacterBody3D
#Señales
signal sprinting_changed(is_sprinting)

@export_group("Components")
@export var view: Node3D

@export_group("Properties")
@export_group("Properties/Movement")
@export var walking_speed = 1.5
@export var running_speed = 4.0
@export var sprint_speed = 7.0

@export var jump_velocity = 4.5
 
@export_group("Control Properties")
@export var controller_value_stick_to_start_run = 0.6

@onready var visuals = $visuals
@onready var animation_player = $AnimationPlayer
var rotation_direction: float

var SPEED = walking_speed
var is_locked = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Engine.max_fps = 60;

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	# Manda una señal a View para el fov de la camara
	sprinting_changed.emit(false)
	
	if animation_player.current_animation == "Movement/sword_slash_1":
		var progress = animation_player.current_animation_position / animation_player.current_animation_length
		if progress >= 0.65:
			is_locked = false
	
	if not animation_player.is_playing() and animation_player.current_animation != "Movement/sword_slash_1":
		is_locked = false
	
	if Input.is_action_just_pressed("attack"):
		if animation_player.current_animation != "Movement/sword_slash_1":
			animation_player.play("Movement/sword_slash_1", -1, 1.4)
			is_locked = true

	# Aplicar gravedad
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Obtener dirección de entrada sin modificar estados
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if not is_locked:
			visuals.look_at(position + direction)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if not is_locked:
		move_and_slide()
