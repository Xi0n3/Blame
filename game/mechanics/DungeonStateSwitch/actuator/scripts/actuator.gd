extends StaticBody3D

@export_enum("Lunar", "Solar")
var typeEnergy := 0  # 0 = Lunar, 1 = Solar

signal actuator_triggered(attacker, actuator)

@onready var item_box = $"actuatorModel/item-box"
@onready var light: OmniLight3D = $actuatorModel/OmniLight3D
@onready var area = $Area3D

# Rotación por segundo
var rotation_speed_deg := 90.0

func _ready():
	# Asegurarse de que el actuador está en el grupo correcto
	add_to_group("actuators")
	
	# Conectar la señal area_entered al manejador
	area.area_entered.connect(_on_area_entered)

func _process(delta):
	$actuatorModel.rotate_y(deg_to_rad(rotation_speed_deg * delta))

func _on_area_entered(area):
	if area:
		# Verificamos si el área tiene la propiedad wielder de forma segura
		var attacker = null
		if area.get("wielder") != null:
			attacker = area.wielder
		
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
		
#Receptor
#func _on_actuator_triggered(attacker, actuator):
	#if actuator.typeEnergy == 1:
		#print("¡Es un actuator solar!")
