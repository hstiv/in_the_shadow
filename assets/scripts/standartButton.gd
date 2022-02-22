extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal pressed
export (String) var text = ''
# Called when the node enters the scene tree for the first time.
func _ready():
	$Button.text = text


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	emit_signal("pressed")




func _on_StandartButton_resized():
	print(rect_size)
	$Button.rect_size = rect_size
