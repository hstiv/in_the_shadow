extends Node

########### INFO ###############
#  model loader loads models   #
################################


# Declare member variables here. Examples:
var DEFAULT_PATH = 'res://assets/src/' # in redactor path is used to save CORE puzzles (teapot, globe earth, globe base, elephant
var USER_PATH = 'user://assets/src/' # path is used after export, in redactor will be cleared every zapusk

var MIPP = 'default/' # models init path prefix
var MOPP = 'openned/' # models opened path prefix
var EMPTY_SCENE_PATH = 'res://assets/scenes/emptyScene/EmptyScene.tscn'
var INFO_EXT = '.txt' #extension of shadowmate info.EXTENSION
var shadow_mates = []
var shadow_mates_states = {}
var DEFAULT_SHADOWMATTES_INFO_PATH = 'res://assets/info/'
var USER_SHADOWMATTES_INFO_PATH = 'user://assets/info/'
var STATES_INFO_FILENAME = 'SHADOWMATTES_ABOUT_INFO.txt'

# Called when the node enters the scene tree for the first time.
func _ready():
	print("MLoader init..")
	# for debug
	shadow_mates = []
	shadow_mates_states = {}
	
	# check if CORE puzzles are exist in USER_PATH
	var directory = Directory.new();
	copy_dir(DEFAULT_PATH, USER_PATH + MIPP, true)
	copy_dir(USER_PATH + MIPP, USER_PATH + MOPP, true)
	
	for path in get_dir_contents(USER_PATH + MOPP)[1]:
		shadow_mates.append(path.split('/')[-1])
	
	var saver = {}
	for mate in shadow_mates:
		saver[mate] = 0
	
	copy_dir(DEFAULT_SHADOWMATTES_INFO_PATH, USER_SHADOWMATTES_INFO_PATH, true)

	var file = File.new()	
	file.open(USER_SHADOWMATTES_INFO_PATH + STATES_INFO_FILENAME, File.READ)
	shadow_mates_states = JSON.parse(file.get_as_text()).result
	file.close()
	update_shadow_mattes_states()
			
	print("MLoader inited!")
	
func getShadowMAtteState(shadowMatteName):
	return shadow_mates_states[shadowMatteName]

func setShadowMAtteState(shadowMatteName, value):
	shadow_mates_states[shadowMatteName] = value
	if value >= 2:
		for i in shadow_mates_states:
			if getShadowMAtteState(i) == 0:
				setShadowMAtteState(i, 1)
				break
				
	update_shadow_mattes_states()
	save_shadowmatte_states()

func update_shadow_mattes_states():
	for i in shadow_mates:
		if not i in shadow_mates_states:
			shadow_mates_states[i] = 0
	save_shadowmatte_states()
	print(shadow_mates_states)
	
func save_shadowmatte_states():
	var file = File.new()	
	file.open(USER_SHADOWMATTES_INFO_PATH + STATES_INFO_FILENAME, File.WRITE)
	file.store_string(to_json(shadow_mates_states))
	file.close()
	
func create_shadowmate(info):
	print("new")
	var dir_path = create_directory(USER_PATH + MIPP, info['name'])
	var file = File.new()	
	var dir = Directory.new()
	
	var model_path = dir_path + "model." + info["path_to_model"].split(".")[-1]
	var last_path = info["path_to_model"]
	info["path_to_model"] = model_path
	dir.copy(last_path, model_path)

	var model = MeshInstance.new()
	var modelMesh = str2var(var2str(load(last_path)))
	model.set_mesh(modelMesh)
	info['main'] = dir_path + "main.tscn"
	var emptyScene = load(EMPTY_SCENE_PATH).instance()
	emptyScene.add_child(model)
	model.set_owner(emptyScene)
	var packed_scene = PackedScene.new()
	packed_scene.pack(emptyScene)
	ResourceSaver.save(info['main'], packed_scene)

	file.open(dir_path + 'info' + INFO_EXT, File.WRITE)
	file.store_string(to_json(info))
	file.close()

	file.open(dir_path + 'info' + INFO_EXT, File.WRITE)
	file.store_string(to_json(info))
	file.close()
	
	copy_dir(dir_path, USER_PATH + MOPP + info['name'] + '/', true)
	shadow_mates.append(info['name'])
	update_shadow_mattes_states()
	
func create_directory(in_directory, directory_new):
	var dir = Directory.new()
	dir.open(in_directory)
	dir.make_dir(directory_new)
	return in_directory + directory_new + '/'

func list_files_in_directory(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)

	dir.list_dir_end()

	return files
	
func get_info_about(name):
	var file = File.new()	
	file.open(USER_PATH + MOPP + name + "/" + "info" + INFO_EXT, File.READ)
	var info = JSON.parse(file.get_as_text()).result
	file.close()
	return info

func reset_progress(shadowmate_name):
	var file1 = File.new()	
	file1.open(USER_PATH + MIPP + shadowmate_name + "/" + "info" + INFO_EXT, File.READ)
	var info = file1.get_as_text()
	file1.close()
	
	var file = File.new()	
	file.open(USER_PATH + MOPP + shadowmate_name + '/' + 'info' + INFO_EXT, File.WRITE)
	file.store_string(info)
	file.close()

func save_progress(info):
	var file = File.new()
	var dir = Directory.new()
	var dir_path = USER_PATH + MOPP + info["name"] + '/'

	file.open(dir_path + 'info' + INFO_EXT, File.WRITE)
	file.store_string(to_json(info))
	file.close()

func get_shadow_mates():
	return shadow_mates
	
func copy_dir(fromDir, newDir, soft = false):
	var directory = Directory.new()
	if not directory.dir_exists(newDir):
		var d = newDir.split('//')[0] + '//'
		for i in newDir.replace(d, '').split('/'):
			d = create_directory(d, i)
	var content = get_dir_contents(fromDir)
	var files = content[0]
	var directories = content[1]
	var newDirectories = []
	
	for dir in directories:
		dir = dir.replace(fromDir, '')
		if soft:
			if not directory.dir_exists(newDir + dir):
				newDirectories.append(create_directory((newDir + dir).left((newDir + dir).length() - dir.split('/')[-1].length()), dir.split('/')[-1]))
		else:
			newDirectories.append(create_directory((newDir + dir).left((newDir + dir).length() - dir.split('/')[-1].length()), dir.split('/')[-1]))
	
	for filePath in files:
		filePath = filePath.replace(fromDir, '')
		if soft:
			if not directory.file_exists(newDir + filePath):
				directory.copy(fromDir + filePath, newDir + filePath)
		else:
			directory.copy(fromDir + filePath, newDir + filePath)	

func remove_dir(path):
	var files_and_folders = get_dir_contents(path)
	var dir = Directory.new()
	for file in files_and_folders[0]:
		var err = dir.remove(file)
		if err:
			push_error('ERROR FUNCTION "remove_dir" line 155: Unable to delete file ' + var2str(file) + '\n')

	while len(files_and_folders[1]) > 0:
		for folder in files_and_folders[1]:
			if dir.dir_exists(folder):
				var err = dir.remove(folder)
				if err:
					if err > 1:
						push_error("Error code: " + str(err) + ". Can't delete directory" + folder)
					continue
			files_and_folders[1].remove(folder)
		
func get_dir_contents(rootPath):
	var files = []
	var directories = []
	var dir = Directory.new()

	if dir.open(rootPath) == OK:
		dir.list_dir_begin(true, false)
		_add_dir_contents(dir, files, directories)
	else:
		push_error("An error occurred when trying to access the path.")

	return [files, directories]
	
func _add_dir_contents(dir, files, directories):
	var file_name = dir.get_next()

	while (file_name != ""):
		var path = dir.get_current_dir() + "/" + file_name

		if dir.current_is_dir():
			# print("Found directory: %s" % path)
			var subDir = Directory.new()
			subDir.open(path)
			subDir.list_dir_begin(true, false)
			directories.append(path)
			_add_dir_contents(subDir, files, directories)
		else:
			#print("Found file: %s" % path)
			files.append(path)

		file_name = dir.get_next()

	dir.list_dir_end()
