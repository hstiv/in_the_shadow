extends Control

var model
onready var inputs = {
	'pathToModel': $Params/ScrollContainer/Inputs/ModelPath/Path, 
	'initRotationX': $Params/ScrollContainer/Inputs/InitRotation/Value/X/LineEditX,
	'initRotationY': $Params/ScrollContainer/Inputs/InitRotation/Value/Y/LineEditY,
	'initRotationZ': $Params/ScrollContainer/Inputs/InitRotation/Value/Z/LineEditZ,
	'winRotationX': $Params/ScrollContainer/Inputs/WinRotation/Value/X/LineEditX,
	'winRotationY': $Params/ScrollContainer/Inputs/WinRotation/Value/Y/LineEditY,
	'winRotationZ': $Params/ScrollContainer/Inputs/WinRotation/Value/Z/LineEditZ,
	'name': $Params/ScrollContainer/Inputs/Name/TextName,
	'rotationRound': $Params/ScrollContainer/Inputs/RotationRound/TextRotationRound,
	'scaleX': $Params/ScrollContainer/Inputs/Scale/Value/X/LineEditX,
	'scaleY': $Params/ScrollContainer/Inputs/Scale/Value/Y/LineEditY,
	'scaleZ': $Params/ScrollContainer/Inputs/Scale/Value/Z/LineEditZ
}
# Called when the node enters the scene tree for the first time.
func _ready():
	modulate = 0
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_MenuButton_pressed():
	init_hide()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == 'hide':
		hide()

func _on_AnimationPlayer_animation_started(anim_name):
	if anim_name == 'show':
		show()
		
func init_show():
	$AnimationPlayer.play("show")
func init_hide():
	$AnimationPlayer.play("hide")

func _on_AddButton_pressed():
	var info = {
		"path_to_model": inputs['pathToModel'].text,
		"win_rotation": [
			int(inputs['winRotationX'].text), 
			int(inputs['winRotationY'].text), 
			int(inputs['winRotationZ'].text)
		],
		"init_rotation": {
			1: [
					int(inputs['initRotationX'].text), 
					int(inputs['initRotationY'].text), 
					int(inputs['initRotationZ'].text)
				],
			2: [
					int(inputs['initRotationX'].text), 
					int(inputs['initRotationY'].text), 
					int(inputs['initRotationZ'].text)
				],
			3: [
					int(inputs['initRotationX'].text), 
					int(inputs['initRotationY'].text), 
					int(inputs['initRotationZ'].text)
				]
		},
		"name": inputs['name'].text,
		"rotation_round": int(inputs['rotationRound'].text),
		"scale": [
			abs(float(inputs['scaleX'].text)), 
			abs(float(inputs['scaleY'].text)), 
			abs(float(inputs['scaleZ'].text))
		],
	}
	MLoader.create_shadowmate(info)



func _on_Path_focus_exited():
	var modelka = MeshInstance.new()
	var modelMesh = str2var(var2str(load(inputs['pathToModel'].text)))
	modelka.set_mesh(modelMesh)

	var cube = $View/ViewportContainer/Viewport/Spatial/cube
	
	if cube.get_child_count() >= 2:
		cube.remove_child(cube.get_child(1))
	
	cube.add_child(modelka)
	updateRoom()

func updateRoom():
	var cube = $View/ViewportContainer/Viewport/Spatial/cube
	cube.transform.basis = Basis()
	var init_rotation = [
		int(inputs['initRotationX'].text), 
		int(inputs['initRotationY'].text), 
		int(inputs['initRotationZ'].text)
	]
	var obj_rotation = Vector3(init_rotation[0] / 57.3248, init_rotation[1] / 57.3248, init_rotation[2] / 57.3248)
	cube.rotate_object_local(Vector3(0, 1, 0), obj_rotation.x)
	cube.rotate_object_local(Vector3(1, 0, 0), obj_rotation.y)
	
	var scale = [
			abs(float(inputs['scaleX'].text)), 
			abs(float(inputs['scaleY'].text)), 
			abs(float(inputs['scaleZ'].text))
	]
	if scale[0] * scale[1] * scale[2] != 0:
		#NOTE: must be cube.get_child().setScale
		cube.set_scale(Vector3(scale[0], scale[1], scale[2]))


func _on_DeleteAll_pressed():
	MLoader.remove_dir('user://assets/')
	MLoader._ready()
