class_name PlayerStateOnGround extends PlayerStateBase

func state_input(_event):
	#TODO Lógica pasar a salto
	if player.input_ref.is_button_pressed("jump"):
		
		pass
	if player.input_ref.is_button_pressed("attack"):
		state_machine.change_to(player.states.AttackGround)
		pass

func state_physics_process(delta):
	#para no moverse mientras ataca 
	if direction.length_squared() > 0.01:
		player.visuals.look_at(player.position + direction, Vector3.UP)
	
