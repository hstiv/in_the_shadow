extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var count
var scene
var playAboutInfo = {}
# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("show")
	$Spatial.allow_rotation = false
	# create puzzles grid
	count = 0
	for s in MLoader.get_shadow_mates():
		count += 1
		var sh = load("res://assets/scenes/playScreen/item/Item.tscn").instance()
		sh.set_name(s)
		sh.set_num(count)
		$ScrollContainer/GridContainer.add_child(sh)
		$ScrollContainer/GridContainer.get_child($ScrollContainer/GridContainer.get_child_count() - 1).init(self)
		sh.init(self)
		sh.setStateOpened(MLoader.getShadowMAtteState(s))
		
	$ScrollContainer/GridContainer.rect_min_size[1] = count/3 * 475 - 200

func choosed(shadowmate, difficulty):
	playAboutInfo['name'] = shadowmate
	playAboutInfo['difficulty'] = difficulty
	$Spatial.set_info(MLoader.get_info_about(shadowmate), difficulty)

func reset_data(shadowmate):
	MLoader.reset_progress(shadowmate)
	
func _on_ExitButton_pressed():
	if $VBoxContainer/PLayButton.is_visible():
		scene = load("res://assets/scenes/mainMenu/mainMenu.tscn").instance()
		$AnimationPlayer.play("hide")
	else:
		to_play_scene()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "hide":
		if str(scene) == "room":
			to_room()
			$Spatial/Button.show()
			$Spatial/AnimationPlayer.play("show")
		else:
			get_parent().add_child(scene)
			self.queue_free() 
	elif anim_name == 'win':
		_on_Spatial_back()
		
func to_room():
	$ScrollContainer.hide()
	$VBoxContainer.hide()
	$ColorRect.hide()
	$ColorRect1.hide()
	$Spatial.allow_rotation = true
	$Spatial/Button/Label.self_modulate = 0
	
func to_play_scene():
	$ScrollContainer.show()
	$VBoxContainer.show()
	$ColorRect.show()
	$ColorRect1.show()
	$AnimationPlayer.play("show")
	
func _on_PLayButton_pressed():
	scene = "room"
	$AnimationPlayer.play("hide")


func _on_Spatial_back():
	$Spatial.allow_rotation = false
	$Spatial/AnimationPlayer.play("hide")
	$Spatial/Button.hide()
	to_play_scene()





func _on_Spatial_onWin():
	$AnimationPlayer.play("win")
	#When user complete puzzle
	MLoader.setShadowMAtteState(playAboutInfo['name'], playAboutInfo['difficulty'] + 1)
	$Spatial._on_SaveButton_pressed()
	
