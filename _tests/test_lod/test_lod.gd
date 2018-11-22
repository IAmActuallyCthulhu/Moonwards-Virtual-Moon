extends Spatial
#This script load a zone using a loading point, say
#Neither of these rooms are actually outside or inside
#they are just toggled
export(NodePath) var Connected1
export(NodePath) var Connected2
var inside = false


func _on_Area_area_entered(area):
	print("enter")
	$MeshInstance.hide()
	$MeshInstance2.show()
	pass # Replace with function body.


func _on_Area_area_exited(area):
	print("exit")
	$MeshInstance2.hide()
	$MeshInstance.show()
	pass # Replace with function body.
