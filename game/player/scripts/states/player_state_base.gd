class_name PlayerStateBase extends StateBase

var input_dir: Vector2
var direction: Vector3

var player: CharacterBody3D:
	set(value):
		controlled_node = value
	get:
		return controlled_node

#TODO Al hacer el input manager, intentar remplazar esto por state_physics_process
#Dado a los errores que da actualmente (player=null) por problemas de sincronización con los hilos
#y con state con la variable direction
func _physics_process(delta):
	if player == null:
		#print("Player no esta cargado")
		return
	input_dir = player.input_ref.direction()
	#input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	#print(self.owner.name + str(player.input_ref))
	direction = (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	

func _input(_event):
	#print(self.owner.name + " Directo: " + str(Input.get_vector("move_left", "move_right", "move_up", "move_down")))
	#print(self.owner.name + "IM: " + str(input_dir))
	
	pass
