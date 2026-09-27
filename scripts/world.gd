extends Node2D

const CENA_GOBLIN := preload("res://scenes/goblin.tscn")
const POSICAO_CORACAO_FASE_2 := Vector2(760, 380)

var inimigos_restantes: int = 0
var fase_concluida: bool = false


func _ready() -> void:
	if not Progression.entrada_de_fase_autorizada:
		get_tree().call_deferred("change_scene_to_file", "res://scenes/main_menu.tscn")
		return
	Progression.entrada_de_fase_autorizada = false

	if Progression.fase_atual == 2:
		_configurar_fase_dois()

	var inimigos := get_tree().get_nodes_in_group(&"inimigos")
	inimigos_restantes = inimigos.size()
	for inimigo in inimigos:
		inimigo.death_effect_finished.connect(_ao_inimigo_removido)


func _configurar_fase_dois() -> void:
	for obstaculo in get_children():
		if obstaculo is StaticBody2D and (obstaculo.name.begins_with("Obstacle") or obstaculo.name.begins_with("ForestTree")):
			obstaculo.position = Vector2(1600.0 - obstaculo.position.x, 1200.0 - obstaculo.position.y)

	$Goblin.position = Vector2(700, 500)
	$Goblin2.position = Vector2(1180, 760)
	$HealthPickup.position = POSICAO_CORACAO_FASE_2
	$ForestTree09.position = Vector2(500, 650)
	$ForestTree10.position = Vector2(650, 750)
	$ForestTree11.position = Vector2(450, 750)

	var terceiro_goblin := CENA_GOBLIN.instantiate()
	terceiro_goblin.name = "Goblin3"
	terceiro_goblin.position = Vector2(1430, 310)
	add_child(terceiro_goblin)


func _ao_inimigo_removido() -> void:
	inimigos_restantes -= 1
	if inimigos_restantes > 0 or fase_concluida:
		return

	fase_concluida = true
	Progression.liberar_proxima_fase(Progression.fase_atual)
	if Progression.fase_atual == 1:
		get_tree().change_scene_to_file("res://scenes/reward_screen.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/level_complete.tscn")
