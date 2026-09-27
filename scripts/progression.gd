extends Node

const SAVE_PATH := "user://sapo_sapudo_progress.json"
const FASE_MAXIMA := 2

var fases_liberadas: Array[int] = [1]
var melhorias_escolhidas: Array[String] = []
var fase_atual: int = 1
var entrada_de_fase_autorizada: bool = false


func _ready() -> void:
	_carregar_progresso()


func iniciar_novo_jogo() -> void:
	fases_liberadas = [1]
	melhorias_escolhidas.clear()
	_salvar_progresso()
	iniciar_fase(1)


func iniciar_fase(numero: int) -> void:
	if numero not in fases_liberadas:
		return

	fase_atual = numero
	entrada_de_fase_autorizada = true
	get_tree().change_scene_to_file("res://scenes/world.tscn")


func liberar_proxima_fase(numero: int) -> void:
	var proxima := numero + 1
	if proxima <= FASE_MAXIMA and proxima not in fases_liberadas:
		fases_liberadas.append(proxima)
		fases_liberadas.sort()
		_salvar_progresso()


func escolher_melhoria(melhoria: String) -> void:
	if melhoria not in [&"ataque", &"coracao_extra"]:
		return
	if melhoria not in melhorias_escolhidas:
		melhorias_escolhidas.append(melhoria)
		_salvar_progresso()

	iniciar_fase(fase_atual + 1)


func obter_vida_maxima_sapudo() -> int:
	return 6 + (2 if &"coracao_extra" in melhorias_escolhidas else 0)


func obter_dano_ataque_sapudo() -> int:
	return 1 + (1 if &"ataque" in melhorias_escolhidas else 0)


func voltar_ao_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _carregar_progresso() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var arquivo := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if arquivo == null:
		return

	var dados: Variant = JSON.parse_string(arquivo.get_as_text())
	if not dados is Dictionary:
		return

	melhorias_escolhidas.clear()
	var fases_salvas: Variant = dados.get("fases_liberadas", [1])
	if fases_salvas is Array:
		fases_liberadas.clear()
		for fase in fases_salvas:
			var numero := int(fase)
			if numero >= 1 and numero <= FASE_MAXIMA and numero not in fases_liberadas:
				fases_liberadas.append(numero)

	if 1 not in fases_liberadas:
		fases_liberadas.append(1)
	fases_liberadas.sort()

	var melhorias_salvas: Variant = dados.get("melhorias_escolhidas", [])
	if melhorias_salvas is Array:
		for melhoria in melhorias_salvas:
			var melhoria_carregada := "coracao_extra" if melhoria == "meio_coracao" else str(melhoria)
			if melhoria_carregada in [&"ataque", &"coracao_extra"] and melhoria_carregada not in melhorias_escolhidas:
				melhorias_escolhidas.append(melhoria_carregada)


func _salvar_progresso() -> void:
	var arquivo := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if arquivo == null:
		push_error("Não foi possível salvar o progresso em user://.")
		return

	var dados := {
		"fases_liberadas": fases_liberadas,
		"melhorias_escolhidas": melhorias_escolhidas,
	}
	arquivo.store_string(JSON.stringify(dados, "\t"))
