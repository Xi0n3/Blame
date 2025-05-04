extends PlayerStateOnGround

func start():
	if player.animation_player.current_animation != "Movement/sprint":
		player.animation_player.play("Movement/sprint", 0.3)
	#Manda una señal a View para el fov de la camara
	player.sprinting_changed.emit(true) 

func state_physics_process(delta):
	player.SPEED = player.sprint_speed
	
	player.velocity.x = direction.x * player.SPEED
	player.velocity.z = direction.z * player.SPEED
	player.move_and_slide()

func state_input(_event):
	super.state_input(_event)
	# seria mejor usar el parametro _event para obtener la información del evento
	if !Input.is_action_pressed("sprint"):
		state_machine.change_to(player.states.Running)

func end():
	player.sprinting_changed.emit(false) 
