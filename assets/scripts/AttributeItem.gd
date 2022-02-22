extends Control

var _itemName = ''
var _nameAreaRatio = .5

signal updateValueSectorSize(nameRatio)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setName(newName):
	_itemName = newName
	$Name/Label.text = _itemName
	while $Name/Label.rect_size[0] > rect_size[0] * getNameAreaRatio():
		if $Name/Label.text == '':
			break
		$Name/Label.text = $Name/Label.text.left(-1)
		$Name/Label.rect_size[0] = 0
		
	while $Name/Label.rect_size[0] < rect_size[0] * getNameAreaRatio():
		$Name/Label.text += ' ' 
		$Name/Label.rect_size[0] = 0	
		
	updateValueSectorSize()
func getName():
	return _itemName
func setNameAreaRatio(newRatio):
	_nameAreaRatio = newRatio
	setName(_itemName)
func getNameAreaRatio():
	return _nameAreaRatio
func setSize(size):
	rect_size = size
	print('2')
	setName(getName())

func updateValueSectorSize():
	emit_signal('updateValueSectorSize', getNameAreaRatio())

