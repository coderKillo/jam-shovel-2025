class_name Speedometer
extends Control

var tacho_max_value = 0.0
var tacho_min_value = 0.0
var tacho_value = 0.0

var thermo_max_value = 0.0
var thermo_min_value = 0.0
var thermo_value = 0.0

var speed_value = 0.0

@onready var tacho_marker: Control = $TachoMarkerAxis
@onready var thermo_marker: Control = $ThermoMarkerAxis
@onready var speed_label: Label = $Speed

const THERMO_MAX_ANGLE = 90
const THERMO_MIN_ANGLE = -90

const TACHO_MAX_ANGLE = 30
const TACHO_MIN_ANGLE = -30


func _process(_delta):
	var thermo_norm = (thermo_value - thermo_min_value) / (thermo_max_value - thermo_min_value)
	thermo_marker.rotation_degrees = (
		(thermo_norm * (THERMO_MAX_ANGLE - THERMO_MIN_ANGLE)) + THERMO_MIN_ANGLE
	)

	var tacho_norm = (tacho_value - tacho_min_value) / (tacho_max_value - tacho_min_value)
	tacho_marker.rotation_degrees = (
		(tacho_norm * (TACHO_MAX_ANGLE - TACHO_MIN_ANGLE)) + TACHO_MIN_ANGLE
	)

	speed_label.text = str(int(speed_value / 4))
