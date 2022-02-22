extends ScrollContainer

var ITEM_TYPES = {
	'TextInput': 'res://assets/scenes/attributesDict/items/ItemTextInput.tscn',
	
}
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func addItem(itemType = '', attrs = {}):
	if itemType in ITEM_TYPES:
		var pathToItem = ITEM_TYPES[itemType]
		if itemType == 'TextInput':
			addItemTextInput(pathToItem, attrs)	 
			
func addItemTextInput(pathToItem, attrs):
	var item = load(pathToItem).instance()
	add_child(item)
	item.setName(attrs['name'])
	print($VBoxContainer.rect_size)
	#item.rect_size = rect_size



func _on_Attributes_resized():
	$VBoxContainer.rect_size = rect_size
