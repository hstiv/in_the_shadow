extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var scenes = {
	'AddNewShadowmatic' : load("res://assets/scenes/addNewShadowmatic/AddNewShadowmatic.tscn").instance(),
}
var scene
# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("show")
	for scene in scenes:
		add_child(scenes[scene])
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Exit_pressed():
	scene = "quit"
	$AnimationPlayer.play("hide")

func _on_Play_pressed():
	scene = load("res://assets/scenes/playScreen/PlayScene.tscn").instance()
	$AnimationPlayer.play("hide")
	
func _on_Add_pressed():
	scenes['AddNewShadowmatic'].init_show()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "hide":
		if str(scene) == "quit":
			get_tree().quit()
		else:
			get_parent().add_child(scene)
			self.queue_free()


func _on_Test_pressed():
	scene = load("res://assets/scenes/testPlayScreen/TestPlayScene.tscn").instance()
	$AnimationPlayer.play("hide")
