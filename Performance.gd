extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"



func _process(delta):
	$FPS.text = str(Performance.get_monitor(Performance.TIME_FPS))
	$Objects.text = str(Performance.get_monitor(Performance.RENDER_OBJECTS_IN_FRAME))
	$Vertices.text = str(Performance.get_monitor(Performance.RENDER_VERTICES_IN_FRAME))
	$VRAM.text = str(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED))