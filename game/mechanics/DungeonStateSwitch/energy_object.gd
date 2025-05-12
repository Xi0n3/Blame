extends Node

@export_enum("Lunar", "Solar", "Vacío")
var typeEnergy := 0  # 0 = Lunar, 1 = Solar, 2 = Vacío

@export var apply_transparency := true
@export var enable_collision_switch := true

# Rutas a los materiales predefinidos
const LUNAR_MATERIAL_PATH = "res://game/mechanics/DungeonStateSwitch/energy_object/materials/lunarMaterial.tres"
const SOLAR_MATERIAL_PATH = "res://game/mechanics/DungeonStateSwitch/energy_object/materials/solarMaterial.tres"
const EMPTY_MATERIAL_PATH = "res://game/mechanics/DungeonStateSwitch/energy_object/materials/vacioMaterial.tres"

# Referencias
var parent_body
var mesh_instance
var lunar_material
var solar_material
var empty_material

func _ready():
	# Añadir al grupo de objetos energéticos
	add_to_group("energy_objects")
	print("Me estoy ejecutando")
	# Obtener el nodo padre
	parent_body = get_parent()
	
	# Verificar que el padre sea un cuerpo físico
	if not (parent_body is StaticBody3D or parent_body is RigidBody3D):
		push_error("EnergyObject debe ser hijo de un StaticBody3D o RigidBody3D")
		return
	
	# Buscar la mesh (asumimos estructura simple)
	if parent_body.has_node("MeshInstance3D"):
		mesh_instance = parent_body.get_node("MeshInstance3D")
	else:
		# Buscar de forma más genérica
		for child in parent_body.get_children():
			if child is MeshInstance3D:
				mesh_instance = child
				break
	
	if not mesh_instance:
		push_warning("No se encontró MeshInstance3D para el objeto de energía")
		return
	
	# Cargar los materiales predefinidos
	lunar_material = load(LUNAR_MATERIAL_PATH)
	solar_material = load(SOLAR_MATERIAL_PATH)
	empty_material = load(EMPTY_MATERIAL_PATH)
	
	if not lunar_material or not solar_material or not empty_material:
		push_error("No se pudieron cargar todos los materiales de energía")
		return
	
	# Buscar el manager y conectarse a la señal
	var manager = find_energy_manager()
	if manager and manager.has_signal("dungeon_energy_changed"):
		manager.connect("dungeon_energy_changed", update_energy_state)
	
	# Actualizar estado inicial
	if manager:
		update_energy_state(manager.current_dungeon_energy)

# Buscar el manager de energía
func find_energy_manager():
	var nodes = get_tree().get_nodes_in_group("dungeon_manager")
	if nodes.size() > 0:
		return nodes[0]
	return null

# Actualizar el estado basado en la energía de la mazmorra
func update_energy_state(dungeon_energy):
	var manager = find_energy_manager()
	if not manager:
		return
	
	var active = false
	
	# Comprobar si este objeto debe estar activo
	match typeEnergy:
		0:  # Lunar
			active = (dungeon_energy == manager.EnergyState.LUNAR)
		1:  # Solar
			active = (dungeon_energy == manager.EnergyState.SOLAR)
		2:  # Vacío
			active = (dungeon_energy == manager.EnergyState.EMPTY)
	
	# Activar/desactivar colisiones
	if enable_collision_switch:
		for child in parent_body.get_children():
			if child is CollisionShape3D or child is CollisionPolygon3D:
				child.disabled = !active
	
	# Aplicar el material correspondiente
	if mesh_instance:
		var material = null
		
		# Seleccionar el material según el tipo de energía
		match typeEnergy:
			0: material = lunar_material  # Lunar
			1: material = solar_material  # Solar
			2: material = empty_material  # Vacío
		
		# Aplicar el material
		if material:
			# Crear una instancia única del material para poder modificar su opacidad
			var instance_material = material.duplicate()
			
			# Configurar transparencia si está inactivo
			if not active and apply_transparency:
				instance_material.flags_transparent = true
				instance_material.albedo_color.a = 0.3  # 30% de opacidad
			else:
				instance_material.flags_transparent = false
				instance_material.albedo_color.a = 1.0  # 100% de opacidad
			
			# Aplicar el material
			mesh_instance.set_surface_override_material(0, instance_material)
