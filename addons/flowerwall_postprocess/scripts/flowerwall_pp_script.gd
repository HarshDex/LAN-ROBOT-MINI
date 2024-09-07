extends Control

@export var dither: CanvasLayer
@export var preblur_x: CanvasLayer
@export var preblur_y: CanvasLayer
@export var crt: CanvasLayer
@export var bloom: CanvasLayer

@onready var dither_shader: Material = dither.get_child(0).get_material()
@onready var crt_shader: Material = crt.get_child(0).get_material()
@onready var preblur_x_shader: Material = preblur_x.get_child(0).get_material()
@onready var preblur_y_shader: Material = preblur_y.get_child(0).get_material()
@onready var bloom_shader: Material = bloom.get_child(0).get_material()

func _ready() -> void:
	# Hardcoding High Res preset values

	# Dithering settings
	dither_shader.set("shader_parameter/dithering", true)
	dither_shader.set("shader_parameter/resolution_scale", 1.0)
	dither_shader.set("shader_parameter/color_depth", 8)

	# Preblur settings
	preblur_x.visible = false
	preblur_y.visible = false
	preblur_x_shader.set("shader_parameter/radius", 0.0)
	preblur_y_shader.set("shader_parameter/radius", 0.0)

	# Grain settings
	crt_shader.set("shader_parameter/enable_grain", true)
	crt_shader.set("shader_parameter/grain_strength", 0.3)

	# Scanlines settings
	crt_shader.set("shader_parameter/enable_scanlines", false)
	crt_shader.set("shader_parameter/scanline_opacity", 0.0)

	# Curvature settings
	crt_shader.set("shader_parameter/enable_curving", false)
	crt_shader.set("shader_parameter/curve_power", 1.0)

	# Vignette settings
	crt_shader.set("shader_parameter/enable_vignette", true)
	crt_shader.set("shader_parameter/vignette_size", 0.4)
	crt_shader.set("shader_parameter/vignette_smoothness", 0.05)

	# VHS Wiggle settings
	crt_shader.set("shader_parameter/enable_vhs_wiggle", false)
	crt_shader.set("shader_parameter/wiggle", 0.0)

	# Chromatic Aberration settings
	crt_shader.set("shader_parameter/enable_chromatic_aberration", false)
	crt_shader.set("shader_parameter/chromatic_aberration_strength", 0.0)

	# CRT and Brightness settings
	crt_shader.set("shader_parameter/enable_rgb_grid", false)
	crt_shader.set("shader_parameter/brightness_multiplier", 1.0)

	# Bloom settings
	bloom.visible = false
	bloom_shader.set("shader_parameter/bloom_threshold", 0.0)
	bloom_shader.set("shader_parameter/bloom_intensity", 0.0)

