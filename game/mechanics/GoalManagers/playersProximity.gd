extends Node3D

# Configuración de los personajes a monitorear
@export var characters: Array[CharacterBody3D] = []
@export var distance_threshold: float = 3.0  # Distancia en unidades del mundo para activar el diálogo
@export var check_interval: float = 0.5  # Intervalo de comprobación en segundos

# Referencias de la UI
@export var dialog_scene: PackedScene  # Escena del diálogo a instanciar
var dialog_instance = null
var is_dialog_shown = false

# Timer para controlar la frecuencia de comprobación
var check_timer: Timer

func _ready():
	# Verificar que tenemos al menos dos personajes para comparar
	if characters.size() < 2:
		push_warning("ProximityGameManager: Se necesitan al menos 2 personajes para monitorear")
	
	# Configurar el timer
	check_timer = Timer.new()
	check_timer.wait_time = check_interval
	check_timer.autostart = true
	check_timer.timeout.connect(_check_proximity)
	add_child(check_timer)
	
	print("ProximityGameManager inicializado. Monitoreando", characters.size(), "personajes")

func _check_proximity():
	# Si ya se mostró el diálogo, no seguir comprobando
	if is_dialog_shown:
		return
	
	# Verificar que tengamos suficientes personajes válidos
	var valid_characters = []
	for character in characters:
		if character != null:
			valid_characters.append(character)
	
	if valid_characters.size() < 2:
		return
	
	# Comprobar la distancia entre todos los pares de personajes
	var all_close = true
	
	# Comprobamos si todos los personajes están suficientemente cerca entre sí
	for i in range(valid_characters.size() - 1):
		for j in range(i + 1, valid_characters.size()):
			var char1 = valid_characters[i]
			var char2 = valid_characters[j]
			
			var distance = char1.global_position.distance_to(char2.global_position)
			
			if distance > distance_threshold:
				all_close = false
				break
		
		if not all_close:
			break
	
	# Si todos están lo suficientemente cerca, mostrar el diálogo
	if all_close:
		show_completion_dialog()

func show_completion_dialog():
	# Evitar mostrar múltiples diálogos
	if is_dialog_shown:
		return
	
	print("¡Todos los personajes están cerca! Mostrando diálogo de completado")
	is_dialog_shown = true
	
	# Si se proporciona una escena de diálogo, instanciarla
	if dialog_scene:
		dialog_instance = dialog_scene.instantiate()
		get_tree().root.add_child(dialog_instance)
		
		# Si el diálogo tiene un método para configurar el texto, usarlo
		if dialog_instance.has_method("set_text"):
			dialog_instance.set_text("¡Completado!")
		
		# Si el diálogo tiene una señal de cierre, conectarla
		if dialog_instance.has_signal("dialog_closed"):
			dialog_instance.connect("dialog_closed", _on_dialog_closed)
	else:
		# Crear un diálogo simple como alternativa
		create_simple_dialog()

func create_simple_dialog():
	# Crear un panel de diálogo simple si no hay escena personalizada
	var panel = Panel.new()
	panel.name = "CompletionDialog"
	
	# Configurar tamaño y posición
	panel.custom_minimum_size = Vector2(300, 100)
	panel.size = Vector2(300, 100)
	panel.position = Vector2(get_viewport().size.x / 2 - 150, get_viewport().size.y / 2 - 50)
	
	# Añadir un label
	var label = Label.new()
	label.text = "¡Completado!"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.custom_minimum_size = panel.custom_minimum_size
	panel.add_child(label)
	
	# Añadir un botón para cerrar
	var button = Button.new()
	button.text = "Cerrar"
	button.position = Vector2(panel.size.x / 2 - 40, panel.size.y - 30)
	button.size = Vector2(80, 25)
	button.pressed.connect(_on_close_button_pressed.bind(panel))
	panel.add_child(button)
	
	# Añadir a la escena
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 10  # Capa alta para estar por encima de otros elementos
	get_tree().root.add_child(canvas_layer)
	canvas_layer.add_child(panel)
	
	dialog_instance = canvas_layer

func _on_close_button_pressed(panel):
	if panel and is_instance_valid(panel):
		if panel.get_parent():
			panel.get_parent().queue_free()
	
	# Permitir que el diálogo se muestre nuevamente
	is_dialog_shown = false

func _on_dialog_closed():
	if dialog_instance and is_instance_valid(dialog_instance):
		dialog_instance.queue_free()
	
	# Permitir que el diálogo se muestre nuevamente
	is_dialog_shown = false

# Método para reiniciar el estado (por ejemplo, después de completar una sección)
func reset():
	is_dialog_shown = false
	if dialog_instance and is_instance_valid(dialog_instance):
		dialog_instance.queue_free()
		dialog_instance = null
