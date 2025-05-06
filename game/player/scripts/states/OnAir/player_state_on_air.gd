class_name PlayerStateOnAir extends PlayerStateBase

var gravity:float = ProjectSettings.get_setting("physics/3d/default_gravity")

func handle_gravity(delta):
	controlled_node.velocity.y += gravity * delta
	## Add the gravity.
	#if not is_on_floor():
		#velocity.y -= gravity * delta
