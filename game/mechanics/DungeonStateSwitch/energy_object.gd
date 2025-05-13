extends StaticBody3D

@export_enum("Lunar", "Solar", "Vacío")
var typeEnergy := 0  # 0 = Lunar, 1 = Solar, 2 = Vacío
@export var apply_transparency := true
@export var enable_collision_switch := true
@export var preview_material_in_editor := true

# Rutas a los materiales predefinidos
const LUNAR_MATERIAL_PATH = "res://game/mechanics/DungeonStateSwitch/energy_object/materials/lunarMaterial.tres"
const SOLAR_MATERIAL_PATH = "res://game/mechanics/DungeonStateSwitch/energy_object/materials/solarMaterial.tres"
const EMPTY_MATERIAL_PATH = "res://game/mechanics/DungeonStateSwitch/energy_object/materials/vacioMaterial.tres"

# Referencias
var mesh_instance
var lunar_material
var solar_material
var empty_material
var original_material
var has_custom_material := false

func _ready():
	# Añadir al grupo de objetos energéticos
	add_to_group("energy_objects")
	print("EnergyObject inicializándose...")
	
	# Buscar la mesh
	if has_node("MeshInstance3D"):
		mesh_instance = get_node("MeshInstance3D")
		print("MeshInstance3D encontrada directamente: ", mesh_instance.name)
	else:
		# Buscar de forma más genérica
		for child in get_children():
			if child is MeshInstance3D:
				mesh_instance = child
				print("MeshInstance3D encontrada en búsqueda: ", child.name)
				break
	
	if not mesh_instance:
		push_warning("No se encontró MeshInstance3D para el objeto de energía")
		return
	
	# Guardar material original si existe
	var current_material = mesh_instance.get_surface_override_material(0)
	if current_material:
		original_material = current_material
		has_custom_material = true
		print("Material personalizado detectado y guardado")
	
	# Cargar los materiales predefinidos
	print("Intentando cargar materiales...")
	
	lunar_material = load(LUNAR_MATERIAL_PATH)
	if lunar_material:
		print("Material lunar cargado correctamente")
	else:
		push_error("No se pudo cargar el material lunar desde: ", LUNAR_MATERIAL_PATH)
	
	solar_material = load(SOLAR_MATERIAL_PATH)
	if solar_material:
		print("Material solar cargado correctamente")
	else:
		push_error("No se pudo cargar el material solar desde: ", SOLAR_MATERIAL_PATH)
	
	empty_material = load(EMPTY_MATERIAL_PATH)
	if empty_material:
		print("Material vacío cargado correctamente")
	else:
		push_error("No se pudo cargar el material vacío desde: ", EMPTY_MATERIAL_PATH)
	
	if not lunar_material or not solar_material or not empty_material:
		push_error("No se pudieron cargar todos los materiales de energía")
		return
	
	# Buscar el manager y conectarse a la señal
	print("Buscando el manager de energía...")
	var manager = find_energy_manager()
	if manager:
		print("Manager encontrado: ", manager.name)
		if manager.has_signal("dungeon_energy_changed"):
			print("Conectando a la señal dungeon_energy_changed")
			manager.connect("dungeon_energy_changed", update_energy_state)
		else:
			push_error("El manager no tiene la señal dungeon_energy_changed")
	else:
		push_warning("No se encontró el manager de energía. Asegúrate de que está en el grupo 'dungeon_manager'")
	
	# Actualizar estado inicial
	if manager:
		print("Actualizando estado inicial. Estado actual del manager: ", manager.current_dungeon_energy)
		update_energy_state(manager.current_dungeon_energy)

# Para visualización en el editor
func _enter_tree():
	if Engine.is_editor_hint() and preview_material_in_editor:
		_apply_preview_material()

func _apply_preview_material():
	if not Engine.is_editor_hint():
		return
		
	# Cargar materiales si no están cargados
	if not lunar_material:
		lunar_material = load(LUNAR_MATERIAL_PATH)
	if not solar_material:
		solar_material = load(SOLAR_MATERIAL_PATH)
	if not empty_material:
		empty_material = load(EMPTY_MATERIAL_PATH)
		
	# Buscar la mesh para previsualización
	var preview_mesh
	if has_node("MeshInstance3D"):
		preview_mesh = get_node("MeshInstance3D")
	else:
		for child in get_children():
			if child is MeshInstance3D:
				preview_mesh = child
				break
	
	if preview_mesh:
		# Aplicar material según typeEnergy para visualización en editor
		var preview_material
		match typeEnergy:
			0: preview_material = lunar_material  # Lunar
			1: preview_material = solar_material  # Solar
			2: preview_material = empty_material  # Vacío
		
		if preview_material:
			# Guardar material original
			var current_material = preview_mesh.get_surface_override_material(0)
			if current_material:
				original_material = current_material
			
			# Aplicar material para previsualización
			preview_mesh.set_surface_override_material(0, preview_material)

# Este método se llama cuando typeEnergy cambia en el editor
func _set(property, value):
	if property == "typeEnergy" and Engine.is_editor_hint():
		typeEnergy = value
		_apply_preview_material()
		return true
	return false

# Buscar el manager de energía
func find_energy_manager():
	var nodes = get_tree().get_nodes_in_group("dungeon_manager")
	print("Nodos en grupo 'dungeon_manager': ", nodes.size())
	if nodes.size() > 0:
		return nodes[0]
	return null

# Actualizar el estado basado en la energía de la mazmorra
func update_energy_state(dungeon_energy):
	if Engine.is_editor_hint():
		return
		
	print("Actualizando estado de energía. Estado recibido: ", dungeon_energy)
	
	var manager = find_energy_manager()
	if not manager:
		push_warning("No se pudo encontrar el manager al actualizar el estado")
		return
	
	var active = false
	
	# Comprobar si este objeto debe estar activo
	match typeEnergy:
		0:  # Lunar
			active = (dungeon_energy == manager.EnergyState.LUNAR)
			print("Objeto Lunar, debe estar activo: ", active)
		1:  # Solar
			active = (dungeon_energy == manager.EnergyState.SOLAR)
			print("Objeto Solar, debe estar activo: ", active)
		2:  # Vacío
			active = (dungeon_energy == manager.EnergyState.EMPTY)
			print("Objeto Vacío, debe estar activo: ", active)
	
	# CAMBIO: Invertir la lógica para los objetos de tipo "Vacío"
	var enable_collisions = false
	if typeEnergy == 2:  # Vacío
		# Para objetos vacío, las colisiones se activan cuando el objeto está activo
		enable_collisions = active
	else:  # Lunar o Solar
		# Para Lunar y Solar, las colisiones se desactivan cuando está activo (inverso)
		enable_collisions = !active
	
	# Activar/desactivar colisiones según la nueva lógica
	if enable_collision_switch:
		var collision_count = 0
		for child in get_children():
			if child is CollisionShape3D or child is CollisionPolygon3D:
				child.disabled = !enable_collisions  # Si enable_collisions es true, disabled es false
				collision_count += 1
				print("Colisión ", child.name, " desactivada: ", !enable_collisions)
		
		if collision_count == 0:
			push_warning("No se encontraron nodos de colisión")
	
	# Aplicar el material correspondiente
	if mesh_instance:
		var material = null
		var material_name = ""
		
		# Si hay un material personalizado, usarlo como base
		if has_custom_material and original_material:
			material = original_material.duplicate()
			material_name = "personalizado"
		else:
			# Seleccionar el material según el tipo de energía
			match typeEnergy:
				0:
					material = lunar_material  # Lunar
					material_name = "lunar"
				1:
					material = solar_material  # Solar
					material_name = "solar"
				2:
					material = empty_material  # Vacío
					material_name = "vacío"
		
		print("Tipo de material seleccionado: ", material_name)
		
		# Aplicar el material
		if material:
			# Crear una instancia única del material para poder modificar su opacidad
			var instance_material = material.duplicate()
			
			# Configurar transparencia según la nueva lógica
			if not enable_collisions and apply_transparency:
				instance_material.flags_transparent = true
				instance_material.albedo_color.a = 0.45  # 45% de opacidad
				print("Aplicando material ", material_name, " con transparencia (30%)")
			else:
				instance_material.flags_transparent = false
				instance_material.albedo_color.a = 1.0  # 100% de opacidad
				print("Aplicando material ", material_name, " opaco (100%)")
			
			# Aplicar el material
			print("Aplicando material a ", mesh_instance.name)
			mesh_instance.set_surface_override_material(0, instance_material)
		else:
			push_error("Material nulo para el tipo " + material_name)
	else:
		push_error("No hay MeshInstance3D válida para aplicar material")
