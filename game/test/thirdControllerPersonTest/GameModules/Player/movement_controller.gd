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

@onready var player = $".."
@onready var animation_player = $"../AnimationPlayer"

var current_state: STATE = STATE.IDLE
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
	var direction = Vector3.ZERO
	
	if Input.is_action_pressed("right"):
		direction.x += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("forward"):
		direction.z -= 1
	if Input.is_action_pressed("backward"):
		direction.z += 1
	
	if direction.length() > 0:
		if Input.is_action_pressed("sprint"):
			current_state = STATE.SPRINTING
			player.velocity.x += 7.0
		else:
			current_state = STATE.RUNNING
	else:
		current_state = STATE.IDLE
	
	if Input.is_action_just_pressed("ui_accept") and player.is_on_floor():
		current_state = STATE.JUMPING
		player.velocity.y = 4.5
	
	if not player.is_on_floor():
		current_state = STATE.FALLING
	
	if Input.is_action_just_pressed("attack"):
		current_state = STATE.ATTACKING	

	# Aplicar animaciones según el estado
	match current_state:
		STATE.IDLE:
			animation_player.play("Movement/idle")
		STATE.RUNNING:
			animation_player.play("Movement/run")
		STATE.SPRINTING:
			animation_player.play("Movement/fast_run")
		STATE.JUMPING:
			animation_player.play("Movement/jump")
		STATE.FALLING:
			animation_player.play("Movement/fall")
		STATE.ATTACKING:
			animation_player.play("Movement/sword_slash_1", -1, 1.4)
