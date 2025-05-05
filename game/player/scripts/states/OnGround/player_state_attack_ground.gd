extends PlayerStateOnGround

func start():
	if player.animation_player.current_animation != "PlayerMovement/sword_slash":
		#(animacion, blend, velocity)
		player.animation_player.play("PlayerMovement/sword_slash", 0.3, 1.4)

func state_process(delta):
	if !player.animation_player.is_playing() and player.animation_player.current_animation != "PlayerMovement/sword_slash":
		state_machine.change_to(player.states.Idle) 
	pass

func state_input(_event):
	if player.animation_player.current_animation == "PlayerMovement/sword_slash":
		var progress = player.animation_player.current_animation_position / player.animation_player.current_animation_length
		if progress >= 0.75 && direction:
			state_machine.change_to(player.states.Idle) 
	pass

func state_physics_process(delta):
	pass
