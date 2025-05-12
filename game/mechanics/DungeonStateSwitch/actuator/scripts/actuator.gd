extends StaticBody3D

@export_enum("Lunar", "Solar")
var typeEnergy := 0  # 0 = Lunar, 1 = Solar

signal actuator_triggered(attacker, actuator)

@onready var item_box = $"actuatorModel/item-box"
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
		
		emit_signal("actuator_triggered", attacker, self)
		
		
#Receptor
#func _on_actuator_triggered(attacker, actuator):
	#if actuator.typeEnergy == 1:
		#print("¡Es un actuator solar!")
