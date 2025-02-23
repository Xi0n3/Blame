extends Node

enum STATE {
	IDLE,
	WALKING,
	RUNNING,
	SPRINTING,
	JUMPING,
	FALLING,
	ATTACKING,
}
@onready var visuals = $"../visuals"
@onready var player = $".."
@onready var animation_player = $"../AnimationPlayer"

@onready var SPEED = player.walking_speed
var current_state: STATE = STATE.IDLE
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_locked = false

func _physics_process(delta):
	#Aqui checamos el currentState
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	
	# Aplicar animaciones según el estado
	match current_state:
		STATE.IDLE:
			Idle()
			if direction:
				current_state= STATE.WALKING
		STATE.WALKING:
			if ((abs(input_dir.x) + abs(input_dir.y))>player.controller_value_stick_to_start_run): #NO OLVIDAR PONER !WalkingMode
				current_state = STATE.RUNNING
		STATE.RUNNING:
			
			if Input.is_action_pressed("sprint"):
				current_state = STATE.SPRINTING
		STATE.SPRINTING:
			print()
		#STATE.JUMPING:
		#STATE.FALLING:
		#STATE.ATTACKING:
	GeneralMovement(direction)
	print(current_state)

func Idle():
	current_state = STATE.IDLE
	animation_player.play("Movement/idle")

func Sprint():
	animation_player.play("Movement/fast_run")
	SPEED = player.sprint_speed
	#sprinting_changed.emit(true)


func GeneralMovement(direction):
	if direction:
		if not is_locked:
			visuals.look_at(player.position + direction)
		player.velocity.x = direction.x * SPEED
		player.velocity.z = direction.z * SPEED
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, SPEED)
		player.velocity.z = move_toward(player.velocity.z, 0, SPEED)
