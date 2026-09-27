extends Node

@export var max_hp: int = 4:
	set(value):
		max_hp = maxi(1, value)
		if is_node_ready():
			current_hp = mini(current_hp, max_hp)
			health_changed.emit(current_hp, max_hp)

signal health_changed(current_health: int, maximum_health: int)
signal died

var current_hp: int
var is_dead: bool = false


func _ready() -> void:
	current_hp = max_hp
	health_changed.emit(current_hp, max_hp)


func take_damage(amount: int) -> void:
	if is_dead or amount <= 0:
		return

	current_hp = maxi(0, current_hp - amount)
	health_changed.emit(current_hp, max_hp)

	if current_hp == 0:
		is_dead = true
		died.emit()


func heal(amount: int) -> void:
	if is_dead or amount <= 0:
		return

	current_hp = mini(max_hp, current_hp + amount)
	health_changed.emit(current_hp, max_hp)
