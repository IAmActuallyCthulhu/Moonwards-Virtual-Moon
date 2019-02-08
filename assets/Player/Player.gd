extends KinematicBody
var CHAR_SCALE = Vector3(0.3, 0.3, 0.3)

var facing_dir = Vector3(1, 0, 0)
var movement_dir = Vector3()
var jumping = false
var aimrotation = Vector3()
export(int) var turn_speed = 40
export(bool) var air_idle_deaccel = false
export(bool) var fixed_up = true
export(float) var accel = 19.0
export(float) var deaccel = 14.0
export(float) var sharp_turn_threshold = 140
export(float) var JumpHeight = 1.5
var Captured = true
var chatting = false
export(bool) var AllowChangeCamera = false
export(bool) var FPSCamera = true
export(bool) var thRDPersCamera = false
var flies = false
var translationcamera
var ActionArea = false
var initialized = false
var ismoving = false
var up
var FPS_camera_node
var TRP_camera_node
#State
var input_processing = true setget set_player_input
var nocamera = false setget set_player_nocamera
var name_label
#Options
export(float) var WALKSPEED = 3.1
export(float) var RUNSPEED = 4.5
export(float) var view_sensitivity = 0.5
export var weight= 1
export(NodePath) var Camera = "Pivot/FPSCamera"

##Physics
export(float) var grav = 1.6
var gravity = Vector3(0,-grav,0)

var max_speed = 0.0

var linear_velocity=Vector3()
var hspeed

##Networking
slave var slave_translation 
slave var slave_transform 
slave var slave_linear_vel 


#####################
## Set/Get functions

#disable camera view for the player
func set_player_nocamera(state):
	if initialized:
		nocamera = state
		if nocamera :
			get_node("Pivot").visible = false
			FPS_camera_node.clear_current()
		else:
			get_node("Pivot").visible = true
			FPS_camera_node.make_current()

#Rotates the model to where the camera points
func adjust_facing(p_facing, p_target, p_step, p_adjust_rate, current_gn):
	var n = p_target # Normal
	var t = n.cross(current_gn).normalized()

	var x = n.dot(p_facing)
	var y = t.dot(p_facing)

	var ang = atan2(y,x)

	if (abs(ang) < 0.001): # Too small
		return p_facing

	var s = sign(ang)
	ang = ang*s
	var turn = ang*p_adjust_rate*p_step
	var a
	if (ang < turn):
		a = ang
	else:
		a = turn
	ang = (ang - a)*s

	return (n*cos(ang) + t*sin(ang))*p_facing.length()

func set_player_input(enable):
	if not enable:
		self.get_node(Camera).noinput = true
		Captured = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		self.get_node(Camera).noinput = false
		Captured = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	input_processing = enable


func _input(event):
	########################### MUST BE CHANGED TO RAYCAST
	if initialized:
		var Raycast = FPS_camera_node.get_node("RayCast")
		var collider = Raycast.get_collider()
		var click_position = Raycast.get_collision_point()
		var click_normal = Raycast.get_collision_normal()
		
		if Raycast.is_colliding():
			collider._input_event (get_viewport().get_camera(), event, click_position, click_normal, 0 )
		
	if Input.is_action_pressed("player_toggleinput"):
		input_processing = !input_processing
		set_player_input(input_processing)
		
	if not input_processing:
		return
	
	if Input.is_action_pressed("ui_page_up"):
		if Captured:
			Captured = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Captured = true
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			#############################
	if Input.is_key_pressed(KEY_ESCAPE):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if (Input.is_action_pressed("run")):
		if not flies: 
			max_speed=RUNSPEED
		else: 
			max_speed=RUNSPEED*2
	else:
		if  not flies: 
			max_speed=WALKSPEED
		else:
			max_speed=WALKSPEED*2
	if (Input.is_action_pressed("toggle_fly")):
		if flies:
			flies = false
		else:
			flies = true
	
func _physics_process(delta):
#Changes acceleration and max speed.
	#if not ActionArea:
	#	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	var v_speed 

	if not flies:
		linear_velocity += gravity*delta/weight # Apply gravity
	
	if fixed_up:
		 up = Vector3(0,1,0) # (up is against gravity)
	else:
		 up = -gravity.normalized()
	var vertical_velocity = up.dot(linear_velocity) # Vertical velocity
	var horizontal_velocity = linear_velocity - up*vertical_velocity # Horizontal velocity
	var hdir = horizontal_velocity.normalized() # Horizontal direction
	hspeed = horizontal_velocity.length() # Horizontal speed

#Movement
	var dir = Vector3() # Where does the player intend to walk to
	if initialized:
		var AbsView = (get_tree().get_root().get_node("Camera_FPS/Target").get_global_transform().origin-$Pivot/FPSCamera.get_global_transform().origin).normalized() 
	#This is the global vector for the player to move while flying
	
#THIS BLOCK IS INTENDED FOR FPS CONTROLLER USE ONLY
	var aim = $Pivot/FPSCamera.get_global_transform().basis
	if is_network_master() or not get_tree().has_network_peer():
		if (Input.is_action_pressed("ui_up")) and not chatting:
			ismoving = true
			if not flies:
				dir -= aim[2]
			
			else:
				dir += AbsView
		else:
			ismoving = false
		if (Input.is_action_pressed("ui_down")) and not chatting:
			if not flies:
				dir += aim[2]
			else:
				dir -= AbsView
			ismoving = true
		else:
			ismoving = false
		if (Input.is_action_pressed("ui_left")) and not chatting:
			dir -= aim[0]

			$Pivot/FPSCamera.Znoice =  1*hspeed

		if (Input.is_action_pressed("ui_right")) and not chatting:
			dir += aim[0]
			$Pivot/FPSCamera.Znoice =  -1*hspeed
		
	
		if flies:
			vertical_velocity += dir.y
		rset_unreliable("slave_translation", translation)
		rset_unreliable("slave_transform", $Model.transform)
		rset_unreliable("slave_linear_vel", linear_velocity)
	else:
#		if not (slave_transform == null or slave_translation == null or slave_linear_vel == null or $Yaw.transform == null or linear_velocity == null):
		if not (slave_transform == null or slave_translation == null or slave_linear_vel == null or linear_velocity == null):
			translation = slave_translation
# 			$Yaw.transform = slave_transform
			linear_velocity = slave_linear_vel

	var jump_attempt = (Input.is_action_pressed("jump") or (Input.is_action_pressed("ui_page_up") and flies))and not chatting
	var crouch_attempt = (Input.is_action_pressed("ui_mlook") or (Input.is_action_pressed("ui_page_down") and flies)) and not chatting
	
	
#END OF THE BLOCK


	var target_dir = (dir - up*dir.dot(up)).normalized()

	if (is_on_floor() or flies): #Only lets the character change it's facing direction when it's on the floor or flying.
		var sharp_turn = hspeed > 0.1 and rad2deg(acos(target_dir.dot(hdir))) > sharp_turn_threshold

		if (dir.length() > 0.1 and !sharp_turn):
			if (hspeed > 0.001):
				hdir = adjust_facing(hdir, target_dir, delta, 1.0/hspeed*turn_speed, up)
				facing_dir = hdir

			else:
				hdir = target_dir


			if (hspeed < max_speed):
				hspeed += accel*delta
			else:
				if hspeed > 0:
					hspeed -= deaccel*delta
		else:
			hspeed -= deaccel*delta
			if (hspeed < 0):
				hspeed = 0

		horizontal_velocity = hdir*hspeed

		var mesh_xform = $Model.transform
		var facing_mesh = -mesh_xform.basis[0].normalized()
		facing_mesh = (facing_mesh - up*facing_mesh.dot(up)).normalized()

		if (hspeed>0):
			facing_mesh = adjust_facing(facing_mesh, target_dir, delta, 1.0/hspeed*turn_speed, up)
		var m3 = Basis(-facing_mesh, up, -facing_mesh.cross(up).normalized()).scaled(CHAR_SCALE)

		$Model.set_transform(Transform(m3, mesh_xform.origin))

		if (not jumping and jump_attempt):
			vertical_velocity = JumpHeight
			jumping = true
	else:
		if flies:
			
			if (hspeed < max_speed):
				hspeed += accel*delta
			else:
				if hspeed > 0:
					hspeed -= deaccel*delta
			
		if (vertical_velocity > 0):
			pass
			#print(ANIM_AIR_UP) #Placeholder
		else:
			pass
			#print(ANIM_AIR_DOWN)
		if (dir.length() > 0.1):
			horizontal_velocity += target_dir*accel*delta
				
			if (horizontal_velocity.length() > max_speed):
				horizontal_velocity = horizontal_velocity.normalized()*max_speed
		else:
			if (air_idle_deaccel):
				hspeed = hspeed - (deaccel*0.2)*delta
				if (hspeed < 0):
					hspeed = 0
				horizontal_velocity = hdir*hspeed

	if (jumping and vertical_velocity < 0):
		jumping = false
		
	if flies: 
		if crouch_attempt:
			vertical_velocity -= delta*accel
			
		if jump_attempt:
			vertical_velocity += delta*accel
			
		if vertical_velocity < -0.1:
			vertical_velocity += delta*deaccel
		
		if vertical_velocity > 0.1:
			
			vertical_velocity -= delta*deaccel
			
		if vertical_velocity < 0.1 and vertical_velocity > -0.1:
			vertical_velocity = 0
			
			
		if vertical_velocity > max_speed:
			vertical_velocity = max_speed
	
	linear_velocity = horizontal_velocity + up*vertical_velocity

	if (is_on_floor()):
		movement_dir = linear_velocity

	linear_velocity = move_and_slide(linear_velocity,-gravity.normalized())

	if not nocamera:
		if AllowChangeCamera:
			if Input.is_action_pressed("cameraFPS"): #Not implemented yet
				$Pivot/FPSCamera.make_current()
				$Pivot/FPSCamera.restrictaxis = false

			if Input.is_action_pressed("camera3RD"): #Not implemented yet
				get_node("Pivot/3RDPersCamera").make_current()
				$Pivot/FPSCamera.restrictaxis = false
		aimrotation = $Pivot/FPSCamera.rotation_degrees
		translationcamera=$Pivot/FPSCamera.get_global_transform().origin

func _ready():
	#$Model/Model.get_surface_material(0).albedo_color = options.get("player", "color")
	#if not name_label:
	#	set_player_name(options.get("player", "name"))
	#else:
	#	set_player_name(name_label)
	
	
	CHAR_SCALE = scale
	set_process_input(true)
	if input_processing:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	var Camera_FPS = load("res://assets/Player/FPSCamera.tscn")
	Camera_FPS = Camera_FPS.instance()
	Camera_FPS.target = get_node("Pivot").get_path()
	get_tree().get_root().add_child(Camera_FPS)
	#get_tree().get_root().get_node(FPSCamera/Chat).connect("disable_movement", self, "toggle_chatting")
	initialized = true

func set_player_name(new_name):
	get_node("label").set_text(new_name)
	$Pivot/FPSCamera/Chat.username = new_name
	name_label = new_name
	
func toggle_chatting():
	if chatting:
		chatting = false
	else:
		chatting = true
		
		
