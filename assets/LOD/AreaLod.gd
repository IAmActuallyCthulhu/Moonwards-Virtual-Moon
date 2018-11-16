extends Area

export(NodePath) var RootNode
export(String) var showhide = "interior"
export(String) var hideshow = "exterior"

var root
var nodes_sh
var nodes_hs

func array_add(a, b):
	for i in b:
		a.append(i)
	return a

func obj_has_groups(obj, groups):
	var has = false
	for grp in groups:
		if obj.get_groups().has(grp):
			has = true
			break
	return has

func get_node_list(root, groups):
	var match_obj = []
	var objects = root.get_children()
	objects.append(root)
	while objects.size():
		var obj = objects.pop_front()
		if obj.get_child_count():
			array_add(objects, obj.get_children())
		if obj_has_groups(obj, groups):
			match_obj.append(obj)
	return match_obj

func _ready():
	if not RootNode :
		root = self.get_parent()
	else:
		root = self.get_node(RootNode)
	nodes_sh = get_node_list(root, [showhide])
	nodes_hs = get_node_list(root, [hideshow])
	connect("area_entered", self, "_on_Area_area_entered")
	connect("area_exited", self, "_on_Area_area_exited")
	_on_Area_area_exited("on ready")
	

func _on_Area_area_entered(area):
	print("enter ", area)
	for obj in nodes_sh:
		obj.visible = true
	for obj in nodes_hs:
		obj.visible = false


func _on_Area_area_exited(area):
	print("exit")
	for obj in nodes_sh:
		obj.visible = false
	for obj in nodes_hs:
		obj.visible = true
