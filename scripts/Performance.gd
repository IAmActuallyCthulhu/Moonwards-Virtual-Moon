extends Control

export(NodePath) var source_xyz = "Camera"


func _process(delta):
	$FPS.text = str(Performance.get_monitor(Performance.TIME_FPS))
	$Objects.text = str(Performance.get_monitor(Performance.RENDER_OBJECTS_IN_FRAME))
	$Vertices.text = str(Performance.get_monitor(Performance.RENDER_VERTICES_IN_FRAME))
	$VRAM.text = str(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED))
	
	var xyz = self.get_node(source_xyz)
#	var ORIGIN = xyz.to_global(xyz.transform.origin)
	if xyz :
		var ORIGIN = xyz.translation
		$x.text = str(ORIGIN.x)
		$y.text = str(ORIGIN.y)
		$z.text = str(ORIGIN.z)