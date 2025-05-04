class_name PlayerStateOnGround extends PlayerStateBase

func state_input(_event):
	#TODO Lógica pasar a salto
	if Input.is_action_just_pressed("jump"):
		
		pass
	if Input.is_action_just_pressed("attack"):
		pass
		#if animation_player.current_animation != "Movement/sword_slash_1":
			#animation_player.play("Movement/sword_slash_1", -1, 1.4)
			#is_locked = true
		#region Attack
	#if animation_player.current_animation == "Movement/sword_slash_1":
		#var progress = animation_player.current_animation_position / animation_player.current_animation_length
		#if progress >= 0.65:
			#is_locked = false  # Desbloquea el movimiento cuando la animación llega al 30%
			 #
	#if !animation_player.is_playing() and animation_player.current_animation != "Movement/sword_slash_1":
		#is_locked = false  # Desbloquea completamente cuando la animación termina
		#
	#if Input.is_action_just_pressed("attack"):
		#if animation_player.current_animation != "Movement/sword_slash_1":
			#animation_player.play("Movement/sword_slash_1", -1, 1.4)
			#is_locked = true
		#
	#else:
		#SPEED = walking_speed
		#running= false
	#
	#endregion
