extends Control


func _on_ataque_pressed() -> void:
	Progression.escolher_melhoria("ataque")


func _on_meio_coracao_pressed() -> void:
	Progression.escolher_melhoria("coracao_extra")
