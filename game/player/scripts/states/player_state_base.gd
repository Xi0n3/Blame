class_name PlayerStateBase extends StateBase

var input_dir: Vector2
var direction: Vector3
var is_locked: bool

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
	
	if direction.length_squared() > 0.01:
		player.visuals.look_at(player.position + direction, Vector3.UP)
	
	input_dir = Input.get_vector("left", "right", "forward", "backward")
	direction = (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
