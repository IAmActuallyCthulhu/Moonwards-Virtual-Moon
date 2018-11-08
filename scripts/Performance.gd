extends Control




func _process(delta):
	$FPS.text = str(Performance.get_monitor(Performance.TIME_FPS))
	$Objects.text = str(Performance.get_monitor(Performance.RENDER_OBJECTS_IN_FRAME))
	$Vertices.text = str(Performance.get_monitor(Performance.RENDER_VERTICES_IN_FRAME))
	$VRAM.text = str(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED))
	
	if get_parent() is Camera:
		$x.text = str(get_parent().translation.x)
		$y.text = str(get_parent().translation.y)
		$z.text = str(get_parent().translation.z)