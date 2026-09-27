extends HBoxContainer

const TEXTURA_CORACAO := preload("res://assets/UI/heart_health_blue_horizontal.png")
const TAMANHO_FRAME := Vector2i(16, 16)

@export_range(1, 10, 1) var pontos_por_coracao: int = 2
@export var tamanho_exibicao: Vector2 = Vector2(32, 32)

@onready var sapudo: Node = $"../../Sapudo"

var coracoes: Array[TextureRect] = []


func _ready() -> void:
	sapudo.connect(&"health_changed", _on_health_changed)
	_criar_coracoes(int(sapudo.get(&"max_hp")))
	_atualizar_coracoes(int(sapudo.get(&"current_hp")))


func _on_health_changed(vida_atual: int, vida_maxima: int) -> void:
	var quantidade_necessaria := ceili(float(vida_maxima) / pontos_por_coracao)

	if coracoes.size() != quantidade_necessaria:
		_criar_coracoes(vida_maxima)

	_atualizar_coracoes(vida_atual)


func _criar_coracoes(vida_maxima: int) -> void:
	for coracao in coracoes:
		coracao.queue_free()

	coracoes.clear()

	var quantidade := ceili(float(vida_maxima) / pontos_por_coracao)
	for indice in quantidade:
		var coracao := TextureRect.new()
		var frame := AtlasTexture.new()
		frame.atlas = TEXTURA_CORACAO
		frame.region = Rect2(Vector2.ZERO, TAMANHO_FRAME)

		coracao.texture = frame
		coracao.custom_minimum_size = tamanho_exibicao
		coracao.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		coracao.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		coracao.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		add_child(coracao)
		coracoes.append(coracao)


func _atualizar_coracoes(vida_atual: int) -> void:
	for indice in coracoes.size():
		var vida_no_coracao := clampi(vida_atual - indice * pontos_por_coracao, 0, pontos_por_coracao)
		var frame := _obter_frame(vida_no_coracao)
		var textura := coracoes[indice].texture as AtlasTexture
		textura.region.position.x = frame * TAMANHO_FRAME.x


func _obter_frame(vida_no_coracao: int) -> int:
	if vida_no_coracao >= pontos_por_coracao:
		return 0
	if vida_no_coracao == pontos_por_coracao - 1:
		return 1

	# O spritesheet só possui três estados; o último quadro representa 0 HP.
	return 2
