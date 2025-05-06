extends CharacterBody3D

#Señales
signal sprinting_changed(is_sprinting)

@export_group("Properties")
@export_enum("Luna", "Sol")
var jugador_id := 0

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
@onready var animation_tree = $AnimationTree

var rotation_direction: float

var states:PlayerStatesNames = PlayerStatesNames.new()

var SPEED = walking_speed
var JUMP_VELOCITY = jump_velocity
var running =  false
var walking_mode = false
var is_locked = false
var input_ref = GameInputManager.Player1


var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	#TODO esto no debería estar aquí
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Engine.max_fps = 60;
	
	add_to_group("players")
	if jugador_id == 1:
		input_ref = GameInputManager.Player2

#TODO esto tampoco debería estar aquí
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
		
func assign_input(input: GameInputManager.PlayerInput):
	input_ref = input
