extends Panel

@onready var slider = $MusicLabel/VolumeSlider
const BUS_NAME = "Master"

func _ready():
	# Connect the slider's value_changed signal to our custom function
	slider.value_changed.connect(_on_volume_slider_changed)
	
	# Set initial volume
	var initial_volume = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(BUS_NAME))
	slider.value = db_to_linear(initial_volume)

func _on_volume_slider_changed(value):
	# Convert slider value (0 to 1) to decibels
	var volume_db = linear_to_db(value)
	
	# Set the volume of the specified audio bus
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(BUS_NAME), volume_db)
