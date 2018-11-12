extends Control




func _process(delta):
	$FPS.text = str(Performance.get_monitor(Performance.TIME_FPS))
	$Objects.text = str(Performance.get_monitor(Performance.RENDER_OBJECTS_IN_FRAME))
	$Vertices.text = str(Performance.get_monitor(Performance.RENDER_VERTICES_IN_FRAME))
	$VRAM.text = str(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED))
	
	if get_parent() is Camera:
		var ORIGIN = get_parent().to_global(get_parent().transform.origin)
		$x.text = str(ORIGIN.x)
		$y.text = str(ORIGIN.y)
		$z.text = str(ORIGIN.z)