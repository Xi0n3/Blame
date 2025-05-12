extends PanelContainer

func _process(delta):
	
	if visible:
		$".".add_property("FPS", Performance.get_monitor(Performance.TIME_FPS), 0)
		pass

func add_property(title : String, value, order : int):
	var target
	target = $MarginContainer/VBoxContainer.find_child(title, true, false)
	if !target:
		target = Label.new()
		$MarginContainer/VBoxContainer.add_child(target)
		target.name = title
		target.text = title + ": " + str(value)
	elif visible:
		target.text = title + ": " + str(value)
		$MarginContainer/VBoxContainer.move_child(target, order)
