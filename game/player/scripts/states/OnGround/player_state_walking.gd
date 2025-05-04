extends PlayerStateOnGround

# Called every frame. 'delta' is the elapsed time since the previous frame.
func state_process(delta):
	pass

func start():
	if player.animation_player.current_animation != "Movement/walk":
		player.animation_player.play("Movement/walk", 0.3)


func state_physics_process(delta):
	player.SPEED = player.walking_speed
	
	player.velocity.x = direction.x * player.SPEED
	player.velocity.z = direction.z * player.SPEED
	player.move_and_slide()

func state_input(_event):
	super.state_input(_event)
	# seria mejor usar el parametro _event para obtener la información del evento
	if (!player.walking_mode && (abs(input_dir.x) + abs(input_dir.y))>player.controller_value_stick_to_start_run): 
		state_machine.change_to(player.states.Running)
	elif !direction :
		state_machine.change_to(player.states.Idle)
