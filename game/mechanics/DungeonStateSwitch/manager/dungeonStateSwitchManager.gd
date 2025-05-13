extends Node

# Enum para los estados de energía de la mazmorra
enum EnergyState {EMPTY, LUNAR, SOLAR}

# Estado actual de la mazmorra (por defecto vacío)
var current_dungeon_energy = EnergyState.EMPTY
# Estado anterior, para detectar cambios
var previous_dungeon_energy = EnergyState.EMPTY

# Colores para cada tipo de energía (solo para referencia visual)
const COLOR_EMPTY = Color(0.1, 0.1, 0.1, 0.5)
const COLOR_LUNAR = Color(0.2, 0.4, 1.0, 1.0)
const COLOR_SOLAR = Color(1.0, 0.8, 0.2, 1.0)

# Timer para restaurar el estado a vacío
var reset_timer: Timer

# Señal para notificar cambios de estado
signal dungeon_energy_changed(new_state)

func _ready():
	# Añadir al grupo para que energy_object lo encuentre
	add_to_group("dungeon_manager")
	
	print("DungeonStateSwitchManager inicializado. Estado inicial: VACÍO")
	
	# Crear y configurar el timer
	reset_timer = Timer.new()
	reset_timer.one_shot = true
	reset_timer.wait_time = 1.0
	reset_timer.timeout.connect(_on_reset_timer_timeout)
	add_child(reset_timer)
	
	# Encontrar todos los actuadores en la escena
	var actuadores = get_tree().get_nodes_in_group("actuators")
	print("Actuadores encontrados: ", actuadores.size())
	
	# Conectar la señal de cada uno
	for actuador in actuadores:
		if actuador.has_signal("actuator_triggered"):
			actuador.connect("actuator_triggered", _on_actuator_triggered)
			print("Señal conectada a actuador: ", actuador.name)
		else:
			push_warning("Actuador sin señal actuator_triggered: ", actuador.name)
	
	# Actualizar todos los objetos energéticos al inicio
	call_deferred("update_energy_objects")

# Función que recibe la señal
func _on_actuator_triggered(attacker, actuator):
	print("¡Actuador activado! Tipo: ", "Lunar" if actuator.typeEnergy == 0 else "Solar")
	
	# Guardar el estado anterior
	previous_dungeon_energy = current_dungeon_energy
	
	# Determinar el nuevo estado según el tipo de actuador
	var new_state = EnergyState.LUNAR if actuator.typeEnergy == 0 else EnergyState.SOLAR
	
	# Comprobar si estamos cambiando a un tipo diferente mientras el timer está activo
	if reset_timer.time_left > 0 and previous_dungeon_energy != EnergyState.EMPTY and new_state != previous_dungeon_energy:
		print("¡Cambio rápido detectado! Volviendo a estado vacío")
		switch_dungeon_state(EnergyState.EMPTY)
		reset_timer.stop()
	else:
		# Cambiar al nuevo estado
		switch_dungeon_state(new_state)
		
		# Iniciar el timer solo si estamos cambiando de un estado no vacío a otro estado no vacío
		if previous_dungeon_energy != EnergyState.EMPTY and new_state != EnergyState.EMPTY:
			reset_timer.start()

# Callback del timer
func _on_reset_timer_timeout():
	print("Timer expirado. No se detectó cambio rápido de energía.")

# Cambia el estado de energía de la mazmorra
func switch_dungeon_state(new_state):
	if current_dungeon_energy != new_state:
		var old_state_name = get_current_state_text()
		current_dungeon_energy = new_state
		var new_state_name = get_current_state_text()
		
		print("Cambio de estado: ", old_state_name, " -> ", new_state_name)
		
		# Notificar a todos los objetos sobre el cambio
		print("Emitiendo señal dungeon_energy_changed con valor: ", new_state)
		emit_signal("dungeon_energy_changed", new_state)
		
		# Actualizar todos los objetos con energía
		update_energy_objects()

# Actualiza todos los objetos energéticos en la escena
func update_energy_objects():
	var energy_objects = get_tree().get_nodes_in_group("energy_objects")
	print("Objetos energéticos encontrados: ", energy_objects.size())
	
	for obj in energy_objects:
		if obj.has_method("update_energy_state"):
			print("Actualizando objeto energético: ", obj.get_parent().name)
			obj.update_energy_state(current_dungeon_energy)
		else:
			push_warning("Objeto sin método update_energy_state: ", obj.get_parent().name)

# Obtener el estado actual como texto
func get_current_state_text():
	match current_dungeon_energy:
		EnergyState.EMPTY: return "vacío"
		EnergyState.LUNAR: return "lunar"
		EnergyState.SOLAR: return "solar"
	return "desconocido"

# Función para depuración - llamar desde la consola
func debug_change_state(state_index):
	print("Comando de depuración: Cambiar estado a ", state_index)
	if state_index >= 0 and state_index <= 2:
		switch_dungeon_state(state_index)
	else:
		push_error("Estado inválido. Usar 0=EMPTY, 1=LUNAR, 2=SOLAR")
