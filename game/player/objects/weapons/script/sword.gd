extends Area3D

var wielder

# Añadir al grupo de espadas para identificación
func _ready():
	add_to_group("weapons")
	
	# Encontrar el jugador que es el portador de esta arma
	var node = get_parent()
	while node and not node.is_in_group("players"):
		node = node.get_parent()
	
	wielder = node
	if wielder:
		print("Espada vinculada a: ", wielder.name)
	else:
		push_warning("Espada no pudo encontrar al jugador")


func _on_area_entered(area):
	print("Espada detectó colisión con: ", area.name)
	
	if area.get_parent().is_in_group("actuators"):
		print("Colisión con actuador detectada")
		if area.get_parent().has_signal("actuator_triggered"):
			area.get_parent().emit_signal("actuator_triggered", wielder, area.get_parent())
			print("Señal emitida al actuador")

	elif area.is_in_group("enemies"):
		if wielder and area.has_method("take_damage"):
			area.take_damage(wielder.attack_power)
			print("Daño aplicado a enemigo")
