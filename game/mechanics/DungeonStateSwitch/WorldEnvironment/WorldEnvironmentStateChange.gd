extends Node

# Configuración del WorldEnvironment
@export var world_environment: WorldEnvironment
@export var empty_environment: Environment
@export var lunar_environment: Environment
@export var solar_environment: Environment
@export var transition_duration: float = 1.5  # Duración de la transición en segundos

# Variables internas
var current_environment: Environment
var target_environment: Environment
var transition_timer: float = 0.0
var is_transitioning: bool = false

# Referencias al sistema de energía
var dungeon_manager = null

func _ready():
	# Verificar que tenemos todos los recursos necesarios
	if not world_environment:
		push_error("EnvironmentTransitioner: Se requiere un WorldEnvironment")
		return
	
	if not empty_environment or not lunar_environment or not solar_environment:
		push_error("EnvironmentTransitioner: Se requieren los tres tipos de Environment")
		return
	
	# Buscar el manager de energía
	dungeon_manager = find_energy_manager()
	if dungeon_manager:
		print("EnvironmentTransitioner: Manager de energía encontrado")
		
		# Conectar la señal de cambio de energía
		if dungeon_manager.has_signal("dungeon_energy_changed"):
			dungeon_manager.connect("dungeon_energy_changed", _on_dungeon_energy_changed)
			print("EnvironmentTransitioner: Conectado a la señal dungeon_energy_changed")
		else:
			push_error("EnvironmentTransitioner: El manager no tiene la señal dungeon_energy_changed")
	else:
		push_error("EnvironmentTransitioner: No se encontró el manager de energía")
	
	# Configurar el entorno inicial basado en el estado actual
	if dungeon_manager:
		var initial_state = dungeon_manager.current_dungeon_energy
		set_environment_immediate(initial_state)
		print("EnvironmentTransitioner: Entorno inicial establecido a", get_state_name(initial_state))

func _process(delta):
	# Manejar la transición entre entornos
	if is_transitioning:
		transition_timer += delta
		
		# Calcular factor de interpolación (0 a 1)
		var t = min(transition_timer / transition_duration, 1.0)
		
		# Aplicar una función de suavizado para la transición
		t = ease(t, 0.5)  # Puedes ajustar el valor para diferentes curvas
		
		# Interpolar todos los parámetros relevantes entre los entornos
		interpolate_environments(current_environment, target_environment, t)
		
		# Finalizar la transición cuando se completa
		if transition_timer >= transition_duration:
			is_transitioning = false
			# Asignar directamente el entorno objetivo para evitar desviaciones numéricas
			world_environment.environment = target_environment.duplicate()
			current_environment = world_environment.environment

# Buscar el manager de energía
func find_energy_manager():
	var nodes = get_tree().get_nodes_in_group("dungeon_manager")
	if nodes.size() > 0:
		return nodes[0]
	return null

# Manejador del cambio de estado de energía
func _on_dungeon_energy_changed(new_state):
	print("EnvironmentTransitioner: Detectado cambio a estado", get_state_name(new_state))
	transition_to_environment(new_state)

# Iniciar una transición hacia el nuevo entorno
func transition_to_environment(energy_state):
	# Determinar el entorno objetivo según el estado de energía
	var new_environment
	match energy_state:
		0:  # EMPTY en tu enum
			new_environment = empty_environment
		1:  # LUNAR en tu enum
			new_environment = lunar_environment
		2:  # SOLAR en tu enum
			new_environment = solar_environment
		_:
			push_error("EnvironmentTransitioner: Estado de energía desconocido")
			return
	
	# Si es la primera transición, establecer el entorno actual
	if not current_environment:
		current_environment = world_environment.environment.duplicate()
	
	# Guardar una copia del entorno objetivo
	target_environment = new_environment.duplicate()
	
	# Reiniciar el temporizador de transición
	transition_timer = 0.0
	is_transitioning = true
	
	print("EnvironmentTransitioner: Iniciando transición hacia", get_state_name(energy_state))

# Establecer el entorno inmediatamente sin transición
func set_environment_immediate(energy_state):
	var env
	match energy_state:
		0: env = empty_environment  # EMPTY
		1: env = lunar_environment  # LUNAR
		2: env = solar_environment  # SOLAR
		_:
			push_error("EnvironmentTransitioner: Estado de energía desconocido")
			return
	
	# Aplicar directamente el entorno
	world_environment.environment = env.duplicate()
	current_environment = world_environment.environment
	is_transitioning = false

# Interpolar entre dos entornos
func interpolate_environments(source_env, target_env, t):
	# Asegurarse de que tenemos un entorno válido para trabajar
	if not world_environment.environment:
		world_environment.environment = Environment.new()
	
	var current_env = world_environment.environment
	
	# Interpolar propiedades principales del entorno
	# Ambiente
	current_env.ambient_light_color = source_env.ambient_light_color.lerp(target_env.ambient_light_color, t)
	current_env.ambient_light_energy = lerp(source_env.ambient_light_energy, target_env.ambient_light_energy, t)
	
	# Niebla
	current_env.fog_enabled = target_env.fog_enabled if t > 0.5 else source_env.fog_enabled
	current_env.fog_density = lerp(source_env.fog_density, target_env.fog_density, t)
	current_env.fog_aerial_perspective = lerp(source_env.fog_aerial_perspective, target_env.fog_aerial_perspective, t)
	current_env.fog_height_density = lerp(source_env.fog_height_density, target_env.fog_height_density, t)
	current_env.fog_light_color = source_env.fog_light_color.lerp(target_env.fog_light_color, t)
	current_env.fog_sun_scatter = lerp(source_env.fog_sun_scatter, target_env.fog_sun_scatter, t)
	
	# Iluminación de fondo
	current_env.background_color = source_env.background_color.lerp(target_env.background_color, t)
	current_env.background_energy_multiplier = lerp(source_env.background_energy_multiplier, target_env.background_energy_multiplier, t)
	
	# Brillo
	current_env.glow_enabled = target_env.glow_enabled if t > 0.5 else source_env.glow_enabled
	current_env.glow_intensity = lerp(source_env.glow_intensity, target_env.glow_intensity, t)
	current_env.glow_bloom = lerp(source_env.glow_bloom, target_env.glow_bloom, t)
	
	# Tonemap
	current_env.tonemap_exposure = lerp(source_env.tonemap_exposure, target_env.tonemap_exposure, t)
	current_env.tonemap_white = lerp(source_env.tonemap_white, target_env.tonemap_white, t)
	
	# SSR y SSAO
	current_env.ssr_enabled = target_env.ssr_enabled if t > 0.5 else source_env.ssr_enabled
	current_env.ssao_enabled = target_env.ssao_enabled if t > 0.5 else source_env.ssao_enabled
	
	# Ajustes de cielo
	if source_env.sky and target_env.sky:
		# Si ambos tienen un cielo, interporlar sus propiedades
		if not current_env.sky:
			current_env.sky = source_env.sky.duplicate()
		
		# Interpolar propiedades del cielo si es posible
		# Nota: Verificamos si el cielo tiene ciertas propiedades en lugar de verificar el tipo
		# Esto es más flexible y no requiere importar clases específicas
		
		# Determinar si es un cielo procedural basado en las propiedades disponibles
		var sky = current_env.sky
		var source_sky = source_env.sky
		var target_sky = target_env.sky
		
		# Intentar interpolar propiedades comunes de cielos procedurales
		# Solo accedemos a las propiedades que podrían existir
		if "sky_top_color" in sky and "sky_top_color" in source_sky and "sky_top_color" in target_sky:
			sky.sky_top_color = source_sky.sky_top_color.lerp(target_sky.sky_top_color, t)
			
		if "sky_horizon_color" in sky and "sky_horizon_color" in source_sky and "sky_horizon_color" in target_sky:
			sky.sky_horizon_color = source_sky.sky_horizon_color.lerp(target_sky.sky_horizon_color, t)
			
		if "sun_angle_max" in sky and "sun_angle_max" in source_sky and "sun_angle_max" in target_sky:
			sky.sun_angle_max = lerp(source_sky.sun_angle_max, target_sky.sun_angle_max, t)
			
		if "sun_curve" in sky and "sun_curve" in source_sky and "sun_curve" in target_sky:
			sky.sun_curve = lerp(source_sky.sun_curve, target_sky.sun_curve, t)
	else:
		# Si uno tiene cielo y el otro no, cambiar en el punto medio
		if t > 0.5:
			current_env.sky = target_env.sky.duplicate() if target_env.sky else null
		else:
			current_env.sky = source_env.sky.duplicate() if source_env.sky else null

# Utilidad para obtener el nombre del estado como texto
func get_state_name(state):
	if dungeon_manager:
		match state:
			dungeon_manager.EnergyState.EMPTY: return "vacío"
			dungeon_manager.EnergyState.LUNAR: return "lunar"
			dungeon_manager.EnergyState.SOLAR: return "solar"
	
	# Fallback si no hay manager
	match state:
		0: return "vacío"
		1: return "lunar"
		2: return "solar"
	
	return "desconocido"
