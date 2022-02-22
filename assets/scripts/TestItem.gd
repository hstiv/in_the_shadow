extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var shadowmate_name 
var target = null
var difficulty = 1
var is_state_opened = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func setStateOpened(state):
	is_state_opened = state
	var easyMode = $ColorRect2/VBoxContainer/Easy/ColorRect
	var normalMode = $ColorRect2/VBoxContainer/Norm/ColorRect
	var hardMode = $ColorRect2/VBoxContainer/Hard/ColorRect
	
	easyMode.show()
	normalMode.show()
	hardMode.show()
	
	if is_state_opened >= 1:
		easyMode.hide()
	if is_state_opened >= 2:
		normalMode.hide()
	if is_state_opened >= 3:
		hardMode.hide()
		
func init(trg):
	target = trg

func set_name(nm):
	$Name.text = str(nm)
	shadowmate_name = str(nm)

func set_num(num):
	$Label.text = str(num)
	
func _on_Button_pressed():
	$ColorRect2.show()
	$AnimationPlayer.play("show_modes")
	$Timer.start()
	
func _send_choosed_signal():
	target.call("choosed", shadowmate_name, difficulty)

func _on_Button2_pressed():
	target.call("reset_data", shadowmate_name)

func _on_Easy_pressed():
	difficulty = 1
	_send_choosed_signal()

func _on_Norm_pressed():
	difficulty = 2
	_send_choosed_signal()
	
func _on_Hard_pressed():
	difficulty = 3
	_send_choosed_signal()
	
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "hide_modes":
		$ColorRect2.hide()

func _on_Timer_timeout():
	$AnimationPlayer.play("hide_modes")
