extends PlayerStateOnGround

func start():
	if player.animation_player.current_animation != "PlayerMovement/run":
		player.animation_player.play("PlayerMovement/run",  0.3)

func state_physics_process(delta):
	super.state_physics_process(delta)
	player.SPEED = player.running_speed
	
	player.velocity.x = direction.x * player.SPEED
	player.velocity.z = direction.z * player.SPEED
	player.move_and_slide()

func state_input(_event):
	super.state_input(_event)
	
	if Input.is_action_pressed("sprint"):
		state_machine.change_to(player.states.Sprinting)
	elif !(!player.walking_mode && (abs(input_dir.x) + abs(input_dir.y))>player.controller_value_stick_to_start_run):
		state_machine.change_to(player.states.Walking)
