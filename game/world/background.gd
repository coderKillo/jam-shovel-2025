extends Node2D
const KEY: StringName = "ParallaxEnabled"
const SECTION: StringName = AppSettings.APPLICATION_SECTION

@export var scroll_scales = [0.05, 0.1, 0.2, 0.4, 1.0]


func _ready() -> void:
	var parallax_enbaled: int = Config.get_config(SECTION, KEY, true)

	for index in get_child_count():
		var parallax := get_child(index) as Parallax2D
		parallax.scroll_scale.x = scroll_scales[index] if parallax_enbaled else 0.0
