extends Spatial



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
