extends Node

# Enum para los estados de energía de la mazmorra
enum EnergyState {EMPTY, LUNAR, SOLAR}

# Estado actual de la mazmorra (por defecto vacío)
var current_dungeon_energy = EnergyState.EMPTY

# Colores para cada tipo de energía
const COLOR_EMPTY = Color(0.1, 0.1, 0.1, 0.5)  # Negro semitransparente
const COLOR_LUNAR = Color(0.2, 0.4, 1.0, 1.0)  # Azul
const COLOR_SOLAR = Color(1.0, 0.8, 0.2, 1.0)  # Amarillo

# Colores semitransparentes para objetos inactivos
const COLOR_LUNAR_INACTIVE = Color(0.2, 0.4, 1.0, 0.3)  # Azul transparente
const COLOR_SOLAR_INACTIVE = Color(1.0, 0.8, 0.2, 0.3)  # Amarillo transparente

# Señal para notificar cambios de estado
signal dungeon_energy_changed(new_state)

func _ready():
	# Encontrar todos los actuadores en la escena
	var actuadores = get_tree().get_nodes_in_group("actuators")
	
	# Conectar la señal de cada uno
	for actuador in actuadores:
		if actuador.has_signal("actuator_triggered"):
			actuador.connect("actuator_triggered", _on_actuator_triggered)
	
	# Actualizar todos los objetos energéticos al inicio
	update_energy_objects()

# Función que recibe la señal
func _on_actuator_triggered(attacker, actuator):
	# El actuador ya ha verificado la compatibilidad, así que podemos cambiar el estado directamente
	if actuator.typeEnergy == 0:  # Lunar
		switch_dungeon_state(EnergyState.LUNAR)
		print("Mazmorra cambiada a estado lunar por jugador: " + str(attacker.jugador_id))
	elif actuator.typeEnergy == 1:  # Solar
		switch_dungeon_state(EnergyState.SOLAR)
		print("Mazmorra cambiada a estado solar por jugador: " + str(attacker.jugador_id))

# Cambia el estado de energía de la mazmorra
func switch_dungeon_state(new_state):
	if current_dungeon_energy != new_state:
		current_dungeon_energy = new_state
		
		# Notificar a todos los objetos sobre el cambio
		emit_signal("dungeon_energy_changed", new_state)
		
		# Mostrar mensaje del cambio
		var state_name = ""
		match new_state:
			EnergyState.EMPTY: state_name = "vacío"
			EnergyState.LUNAR: state_name = "lunar"
			EnergyState.SOLAR: state_name = "solar"
		
		print("La mazmorra ahora está en estado: " + state_name)
		
		# Actualizar todos los objetos con energía
		update_energy_objects()

# Actualiza todos los objetos energéticos en la escena
func update_energy_objects():
	var energy_objects = get_tree().get_nodes_in_group("energy_objects")
	for obj in energy_objects:
		if obj.has_method("update_energy_state"):
			obj.update_energy_state(current_dungeon_energy)

# Obtener el estado actual como texto
func get_current_state_text():
	match current_dungeon_energy:
		EnergyState.EMPTY: return "vacío"
		EnergyState.LUNAR: return "lunar"
		EnergyState.SOLAR: return "solar"
	return "desconocido"
