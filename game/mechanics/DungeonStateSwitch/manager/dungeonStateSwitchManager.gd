extends Node

func _ready():
	# Encontrar todos los actuadores en la escena
	var actuadores = get_tree().get_nodes_in_group("actuators")
	
	# Conectar la señal de cada uno
	for actuador in actuadores:
		if actuador.has_signal("actuator_triggered"):
			actuador.connect("actuator_triggered", _on_actuator_triggered)

# Función que recibe la señal
func _on_actuator_triggered(attacker, actuator):
	if actuator.typeEnergy == 1:
		
		print("activate cagada, atacante: "+ str(attacker.jugador_id) +" SOLAR")
	else:
		print("activate cagada, atacante: ", attacker.jugador_id ," LUNAR")
	
	# Aquí puedes implementar la lógica de lo que ocurre cuando se activa
