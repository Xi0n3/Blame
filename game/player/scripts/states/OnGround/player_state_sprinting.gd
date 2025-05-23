extends PlayerStateOnGround

func start():
	if player.animation_player.current_animation != "PlayerMovement/sprint":
		player.animation_player.play("PlayerMovement/sprint", 0.3)
	#Manda una señal a View para el fov de la camara
	player.sprinting_changed.emit(true) 

func state_physics_process(delta):
	super.state_physics_process(delta)
	player.SPEED = player.sprint_speed
	
	player.velocity.x = direction.x * player.SPEED
	player.velocity.z = direction.z * player.SPEED
	player.move_and_slide()

func state_input(_event):
	super.state_input(_event)

	if !(player.input_ref.is_button_pressed("sprint") && player.input_ref.should_run()):
		state_machine.change_to(player.states.Running)

func end():
	player.sprinting_changed.emit(false) 
