extends SubViewportContainer

func _ready():
	# Asigna las cámaras correctamente
	$SubViewportA.add_child($"../Player/View/SpringArm3D/Camera3D")
	$SubViewportB.add_child($"../Player2/View/SpringArm3D/Camera3D")

	# Ajusta el tamaño de los SubViewports según el contenedor
	$SubViewportA.size = size / Vector2(1, 2)
	$SubViewportB.size = size / Vector2(1, 2)

	
	# Asigna las cámaras a los SubViewports
	$SubViewportA.world_3d = $"../Player/View/SpringArm3D/Camera3D".get_world_3d()
	$SubViewportB.world_3d = $"../Player2/View/SpringArm3D/Camera3D".get_world_3d()


	# Conecta la señal de redimensionado
	resized.connect(_on_viewport_container_resized)

	# Configura el tamaño inicial de los SubViewports
	_on_viewport_container_resized()

func _on_viewport_container_resized():
	# Ajusta el tamaño de los SubViewports según este contenedor
	$SubViewportA.size = Vector2(size.x, size.y / 2)
	$SubViewportB.size = Vector2(size.x, size.y / 2)
