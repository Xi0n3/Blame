extends PlayerStateOnGround

func start():
	if player.animation_player.current_animation != "PlayerMovement/idle":
		#El segundo parametro es de blend
		player.animation_player.play("PlayerMovement/idle", 0.3)


func state_process(delta):
	pass

func state_input(_event):
	super.state_input(_event) #Para heredar el comportamiento de Jump de PlayerStateOnGround
	
	#print("Valor de direction en idle: " + str(direction))
	if direction: 
		state_machine.change_to(player.states.Walking)
