extends Control

var attributeItem
func _ready():
	attributeItem = $AttributeItem

func setName(newName):
	attributeItem.setName(newName)
func getName():
	attributeItem.getName()
func setNameAreaRatio(newRatio):
	attributeItem.setNameAreaRatio(newRatio)
func getNameAreaRatio():
	attributeItem.getNameAreaRatio()

func setSize(size):
	#rect_size = size
	attributeItem.setSize(size)

func _on_AttributeItem_updateValueSectorSize(nameRatio):
	#$AttributeItem/TextEdit.rect_size[0] = $AttributeItem.rect_size[0] * (1 - nameRatio)
	print(rect_size, $AttributeItem.rect_size, $AttributeItem.rect_position[0] + rect_size[0] * nameRatio)
	$AttributeItem/TextEdit.rect_position[0] = $AttributeItem.rect_position[0] + rect_size[0] * nameRatio

func _on_ItemTextInput_resized():
	print('1')
	#attributeItem.setSize(rect_size)
