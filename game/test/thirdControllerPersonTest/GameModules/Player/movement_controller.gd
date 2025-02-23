extends Node

enum {
	IDLE,
	WALKING,
	RUNING,
	SPRINTING,
	JUMPING,
	FALLING,
	ATTACKING,
}
#Nodos
@onready var player = $".."
@onready var animation_player = $"../AnimationPlayer"

var CURRENT_STATE

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

	#SPEED = player.walking_speed
	#JUMP_VELOCITY = player.jump_velocity

func _physics_process(delta):
	print(str(player.walking_speed))
	idle(delta)
	

func idle(delta):
	animation_player.play("Movement/idle")
	not_on_floor(delta)

func walk(delta):
	animation_player.play("Movement/walk")
	not_on_floor(delta)


func not_on_floor(delta):
	print("gravity")
	#player.velocity.y -= gravity * delta
