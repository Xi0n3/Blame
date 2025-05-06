class_name StateMachine extends Node

#Nodo a controlar (En este caso el padre)
@onready var controlled_node = self.owner

#Estado por defecto
@export var default_state:StateBase

#Estado de entrada (vacio)
var current_state:StateBase = null

# "-> void" el tipo de dato que devuelve
func _ready() -> void:
	#call_deferred se ejecuta al final del frame para asegurar que todo este cargado en el nodo
	call_deferred("_state_default_start")

func _state_default_start() -> void:
	current_state = default_state
	_state_start()


#Prepara las variables para el nuevo estado y ejecuta su start
func _state_start():
	#prints("StateMachine", controlled_node.name, "start state: ", current_state.name)
	#Se configura el objeto current_state (el estado)
	current_state.controlled_node = controlled_node
	current_state.state_machine = self
	current_state.start()
	
	pass

#Cambia a un nuevo estado
func change_to(new_state:String) -> void:
	if current_state && current_state.has_method("end"): current_state.end()
	current_state = get_node(new_state)
	_state_start()

#region Delegación de responsabilidades de los metodos del nodo
#Se llaman a los metodos del currentState desde aquí, para que solo el nodo activo ejecute los metodos

func _process(delta: float) -> void:
	if current_state && current_state.has_method("state_process"):
		current_state.state_process(delta)

func _physics_process(delta: float) -> void:
	if current_state && current_state.has_method("state_physics_process"):
		current_state.state_physics_process(delta)

func _input(event: InputEvent) -> void:
	if current_state && current_state.has_method("state_input"):
		current_state.state_input(event)

func _unhandled_input(event: InputEvent) -> void:
	if current_state && current_state.has_method("state_unhandled_input"):
		current_state.state_unhandled_input(event)

func _unhandled_key_input(event: InputEvent) -> void:
	if current_state && current_state.has_method("state_unhandled_key_input"):
		current_state.state_unhandled_key_input(event)

#endregion 
