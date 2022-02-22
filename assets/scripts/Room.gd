extends Spatial

signal back
signal save
signal onWin

var is_rotating = false
var last_position = [0, 0]
var allow_rotation = false
var win_auto_rotation = false
var auto_rotation_speed = 1
var min_rad = 1 * (3.14 / 180) #convert to radians
var win_rotation = Vector3(0, 0, 0)
var speed = .01
var choosed_object
var info = null 
var obj_rotation = Vector3(0, 0, 0)
var prefVector = Vector3(1, 0, 1)
var PUZZLE_DIFFICULTY = '0'

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

#Called when shamdowmatic model was set and play buttons pressed, init object 
func set_info(inf, difficulty):
	is_rotating = false
	allow_rotation = false
	win_auto_rotation = false
	
	info = inf
	PUZZLE_DIFFICULTY = str(difficulty)
	#--- Init model.obj from shadowmatic info ---#
	#remove the last children, but keep alive first child because it is a collision shape
	if $cube.get_child_count() >= 2:
		$cube.remove_child($cube.get_child(1))
	
	var modelka = load(info["main"]).instance()
	$cube.add_child(modelka)
	
	#--- Set the obj rotation from info ---#
	# NOTE: in info.csv the rotations are saved in degrees, but our main loop uses radioans, so converting it
	if difficulty == 1:
		obj_rotation = Vector3(info["init_rotation"][PUZZLE_DIFFICULTY][0] / 57.3248, info["win_rotation"][1] / 57.3248, info["init_rotation"][PUZZLE_DIFFICULTY][2] / 57.3248)
	elif difficulty >= 2:
		obj_rotation = Vector3(info["init_rotation"][PUZZLE_DIFFICULTY][0] / 57.3248, info["init_rotation"][PUZZLE_DIFFICULTY][1] / 57.3248, info["init_rotation"][PUZZLE_DIFFICULTY][2] / 57.3248)
	$cube.transform.basis = Basis()
	$cube.rotate_object_local(Vector3(0, 1, 0), obj_rotation.x)
	$cube.rotate_object_local(Vector3(1, 0, 0), obj_rotation.y)
	win_rotation = Vector3(info["win_rotation"][0] / 57.3248, info["win_rotation"][1] / 57.3248, info["win_rotation"][2] / 57.3248)
	
	#--- Set model scale from info ---#
	if info["scale"][0] * info["scale"][1] * info["scale"][2] != 0:
		modelka.set_scale(Vector3(info["scale"][0], info["scale"][1], info["scale"][2]))
	
func _input(event):
#--- Rotating objects by mouse ---#
	#--- Raytrace (choose) object to rotate ---#
	if event is InputEventMouseButton:
		if event.button_index == 1:
			is_rotating = !is_rotating
			var space_state = get_world().direct_space_state
			var mouse_position = get_viewport().get_mouse_position()
			var ray_origin = $Camera.project_ray_origin(mouse_position)
			var ray_end = ray_origin + $Camera.project_ray_normal(mouse_position) * 200
			var intersection = space_state.intersect_ray(ray_origin, ray_end)
			if not intersection.empty():
				choosed_object = intersection.collider.get_parent() 
			else:
				choosed_object = null
	
	#--- Rotate choosed object ---#
	if not win_auto_rotation and event is InputEventMouseMotion:
		if is_rotating and allow_rotation:
			if choosed_object:
				var r =  obj_rotation * Vector3(57.3248, 57.3248, 57.3248)
				for i in range(2):
					while abs(r[i]) > 360.0:
						r[i] -= 360.0 * (abs(int(r[i]))/int(r[i]))
				var pog = max(0.1, abs(info["rotation_round"]))

				while abs(pog) > 360:
					pog -= 360 * (abs(int(pog))/int(pog))
				var w = info["win_rotation"]

				if ( (abs(r[0] - w[0]) + abs(r[1] - w[1]))/2.0 <= abs(float(pog))
					or (360 - abs(r[0] - w[0]) + abs(r[1] - w[1]))/2.0 <= abs(float(pog)) 
					or (abs(r[0] - w[0]) + 360 - abs(r[1] - w[1]))/2.0 <= abs(float(pog)) 
					or (360 - abs(r[0] - w[0]) + 360 - abs(r[1] - w[1]))/2.0 <= abs(float(pog))):
				#if abs(sqrt(r[0]*r[0] + r[1]*r[1]) - sqrt(w[0]*w[0] + w[1]*w[1])) <= abs(float(pog)) or 360 - abs(sqrt(r[0]*r[0] + r[1]*r[1]) - sqrt(w[0]*w[0] + w[1]*w[1])) <= abs(float(pog)):
					win_auto_rotation = true
				else:
					obj_rotation += prefVector * Vector3(speed, speed, speed) * Vector3(event.position[0] - last_position[0], event.position[1] - last_position[1], 0)
				choosed_object.transform.basis = Basis()
				choosed_object.rotate_object_local(Vector3(0, 1, 0), obj_rotation.x)
				choosed_object.rotate_object_local(Vector3(1, 0, 0), obj_rotation.y)

		last_position = event.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	prefVector.y = 0
	prefVector.x = 1
	if int(PUZZLE_DIFFICULTY) > 1:
		if Input.is_key_pressed(KEY_CONTROL):
			prefVector.y = 1
			prefVector.x = 0
		if int(PUZZLE_DIFFICULTY) > 2 and Input.is_key_pressed(KEY_SHIFT):
			prefVector.y = 1
			prefVector.x = 1
		
		
	if win_auto_rotation and allow_rotation:
		var counter = 0

		for i in range(2):
			var a = 1000
			var obr = float(int(obj_rotation[i] * a) % int(6.28 * a)) / a
			var wr = float(int(win_rotation[i] * a) % int(6.28 * a)) / a
			if obr < 0.0:
				obr = 6.28 + obr - 6.28 * int(obr / 6.28)
			if obr > 6.28:
				obr -= 6.28 * int(obr / 6.28)
			obj_rotation[i] = obr
			if wr < 0.0:
				wr = 6.28 + wr - 6.28 * int(wr / 6.28)
			if wr > 6.28:
				wr -= 6.28 * int(wr / 6.28)

			if abs(obr - wr) > min_rad and abs(obr - wr) < 6.28 - min_rad and obr - wr != 0:

				if abs(wr - obr) < 3.14:
					obj_rotation[i] += (wr - obr)/abs(wr - obr) * delta * auto_rotation_speed
				else:
					if obr > 3.14:
						obj_rotation[i] += delta * auto_rotation_speed
					elif obr < 3.14:
						obj_rotation[i] -= delta * auto_rotation_speed
					
			else:
				counter += 1
		if counter == 2:
			#----- WIN -----#
			onWin()
		$cube.transform.basis = Basis()
		$cube.rotate_object_local(Vector3(0, 1, 0), obj_rotation.x)
		$cube.rotate_object_local(Vector3(1, 0, 0), obj_rotation.y)
	
func _on_Button_pressed():
	emit_signal("back")

func _on_SaveButton_pressed():
	emit_signal("save")
	# NOTE: in info.csv the rotations are saved in degrees, but our main loop uses radioans, so converting it
	info['init_rotation'][PUZZLE_DIFFICULTY] = [obj_rotation.x * 57.3248, obj_rotation.y * 57.3248, 0]
	MLoader.save_progress(info)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "show":
		allow_rotation = true
	elif anim_name == "hide":
		allow_rotation = false

func onWin():
	emit_signal("onWin")

func getInitCube():
	return $cube
