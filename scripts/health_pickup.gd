extends Area2D

@export var quantidade_cura: int = 1


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group(&"sapudo"):
		return
	if not body.has_method(&"collect_health_pickup"):
		return

	body.call(&"collect_health_pickup", quantidade_cura)
	queue_free()
