class_name PlayerStateOnGround extends PlayerStateBase

func state_input(_event):
	#TODO Lógica pasar a salto
	if Input.is_action_just_pressed("jump"):
		
		pass
	if Input.is_action_just_pressed("attack"):
		state_machine.change_to(player.states.AttackGround)
		pass

func state_physics_process(delta):
	if direction.length_squared() > 0.01:
		player.visuals.look_at(player.position + direction, Vector3.UP)
