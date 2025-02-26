#Este código necesita migrar su movimiento a movement controller, 
#y un Input Controller, ademas de ser más modular, pero todo a su tiempo

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

#Podemos agregar una linea como la de abajo para instanciar un nodo de la escena
#en una variable, simplemente arrastrando el nodo al código mientras mantenemos CTRL
@onready var visuals = $visuals
@onready var animation_player = $AnimationPlayer
var rotation_direction: float

var SPEED = walking_speed
var JUMP_VELOCITY = jump_velocity
var running =  false
var walking_mode = false
var is_locked = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Engine.max_fps = 60;

#Funcion para escuchar cualquier evento
func _process(delta):
	
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if Input.is_action_just_pressed("walking_mode"):
		if walking_mode: walking_mode=false; print("walkmodeOFF")
		else: walking_mode = true;  print("walkmodeON")

func _physics_process(delta):
	#Manda una señal a View para el fov de la camara
	sprinting_changed.emit(false)
		
	if animation_player.current_animation == "Movement/sword_slash_1":
		var progress = animation_player.current_animation_position / animation_player.current_animation_length
		if progress >= 0.65:
			is_locked = false  # Desbloquea el movimiento cuando la animación llega al 30%
			 
	if !animation_player.is_playing() and animation_player.current_animation != "Movement/sword_slash_1":
		is_locked = false  # Desbloquea completamente cuando la animación termina
		
	if Input.is_action_just_pressed("attack"):
		if animation_player.current_animation != "Movement/sword_slash_1":
			animation_player.play("Movement/sword_slash_1", -1, 1.4)
			is_locked = true
		
	else:
		SPEED = walking_speed
		running= false
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if !is_locked:
			if  (!walking_mode && (abs(input_dir.x) + abs(input_dir.y))>controller_value_stick_to_start_run):
				if Input.is_action_pressed("sprint"):
					if animation_player.current_animation != "Movement/fast_run":
						animation_player.play("Movement/fast_run")
					SPEED = sprint_speed
					sprinting_changed.emit(true) 
				else:
					if animation_player.current_animation != "Movement/run":
						animation_player.play("Movement/run")
					SPEED = running_speed
					running = true
			else:
				if animation_player.current_animation != "Movement/walk":
					animation_player.play("Movement/walk")
			visuals.look_at(position + direction)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		if !is_locked:
			if animation_player.current_animation != "Movement/idle":
				animation_player.play("Movement/idle")
		
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	if !is_locked:
		move_and_slide() 
