extends OptionButton


# Called when the node enters the scene tree for the first time.
func _ready():
	add_list()


@onready var menu = $"."


func add_list():
	menu.add_item("Team A")
	menu.add_item("Team B")
	menu.add_item("Team C")
	menu.add_item("Team D")
	menu.add_item("Team E")

