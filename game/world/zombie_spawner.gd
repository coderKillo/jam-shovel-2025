extends TileMapLayer

const SPAWN_DISTANCE = 500.0

@export var player: Player

@onready var zombie_scene = preload("res://game/entities/enemy/zombie.tscn")

var _spawn_positions: Array[Vector2]
var _spawn_index: int


func _ready():
	for cell in get_used_cells():
		_spawn_positions.append(map_to_local(cell))

	_spawn_positions.sort()
	_spawn_index = 0

	hide()


func _process(_delta):
	if _spawn_index >= _spawn_positions.size():
		return

	if _spawn_positions[_spawn_index].distance_to(player.global_position) < SPAWN_DISTANCE:
		_spawn(_spawn_positions[_spawn_index])
		_spawn_index += 1


func _spawn(spawn_position: Vector2):
	var zombie = zombie_scene.instantiate()
	get_parent().add_child(zombie)
	zombie.global_position = spawn_position
