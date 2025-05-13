extends StaticBody3D

@export_enum("Lunar", "Solar")
var typeEnergy := 0  # 0 = Lunar, 1 = Solar

signal actuator_triggered(attacker, actuator)

@onready var item_box = $"actuatorModel/item-box"
@onready var light: OmniLight3D = $actuatorModel/OmniLight3D
@onready var area = $Area3D

# Rotación por segundo
var rotation_speed_deg := 90.0

# Propiedades para animaciones
var original_light_energy: float
var original_box_position: Vector3
var is_active := true

func _ready():
	# Asegurarse de que el actuador está en el grupo correcto
	add_to_group("actuators")
	
	# Conectar la señal area_entered al manejador
	area.area_entered.connect(_on_area_entered)
	
	# Guardar valores originales para animaciones
	original_light_energy = light.light_energy
	original_box_position = item_box.position
	
	# Buscar el manager y conectarse a la señal de cambio de estado
	var manager = find_energy_manager()
	if manager:
		manager.connect("dungeon_energy_changed", _on_dungeon_energy_changed)

func _process(delta):
	$actuatorModel.rotate_y(deg_to_rad(rotation_speed_deg * delta))

# Buscar el manager de energía
func find_energy_manager():
	var nodes = get_tree().get_nodes_in_group("dungeon_manager")
	if nodes.size() > 0:
		return nodes[0]
	return null

# Responder a cambios en el estado de la mazmorra
func _on_dungeon_energy_changed(dungeon_energy):
	var manager = find_energy_manager()
	if not manager:
		return
	
	# Comprobar si este actuador es compatible con el estado actual
	var should_be_active = false
	
	match typeEnergy:
		0:  # Lunar
			should_be_active = (dungeon_energy != manager.EnergyState.LUNAR)
		1:  # Solar
			should_be_active = (dungeon_energy != manager.EnergyState.SOLAR)
	
	# Si el estado de la mazmorra coincide con nuestro tipo, desactivar
	# Si el estado de la mazmorra NO coincide con nuestro tipo, activar
	if should_be_active != is_active:
		is_active = should_be_active
		update_visual_state()

# Actualizar el estado visual del actuador
func update_visual_state():
	if is_active:
		# Actuador activo - valores normales
		if light:
			light.light_energy = original_light_energy
		if item_box:
			item_box.position = original_box_position
	else:
		# Actuador inactivo - bajar intensidad y posición
		if light:
			light.light_energy = original_light_energy * 0.3  # Reducir al 30%
		if item_box:
			# Bajar el item-box (reducir su coordenada Y)
			var lowered_position = original_box_position
			lowered_position.y -= 0.5  # Ajustar según sea necesario
			item_box.position = lowered_position

func _on_area_entered(area):
	if area:
		# Verificamos si el área tiene la propiedad wielder de forma segura
		var attacker = null
		if area.get("wielder") != null:
			attacker = area.wielder
		
		# Solo activar si el actuador está activo visualmente
		if is_active:
			# Verificar compatibilidad de energías
			if attacker:
				if (typeEnergy == 0 and attacker.jugador_id == 0) or (typeEnergy == 1 and attacker.jugador_id == 1):
					# Energías compatibles - emitir señal
					emit_signal("actuator_triggered", attacker, self)
					print("activado huacahuaca, atacante: ", attacker)
				else:
					# Energías incompatibles - mostrar mensaje de bloqueo
					print("Bloqueado: Energías incompatibles")
					if typeEnergy == 0:
						print("Este actuador requiere energía Lunar")
					else:
						print("Este actuador requiere energía Solar")
			else:
				print("No se detectó atacante válido")
		else:
			print("Actuador inactivo - no responde a interacciones")
