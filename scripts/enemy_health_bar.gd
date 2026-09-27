extends Node2D

# A arte útil da base tem 15 px em cada lateral e 64 px no centro.
# A escala visual do Node2D reduz a barra inteira para ~75 px de largura.
const LARGURA_LATERAL := 15.0
const LARGURA_CENTRO := 64.0
const ALTURA_ARTE := 19.0

@export_range(0.4, 1.5, 0.05) var escala_visual: float = 0.8:
	set(value):
		escala_visual = clampf(value, 0.4, 1.5)
		if is_node_ready():
			scale = Vector2.ONE * escala_visual

@export_range(20.0, 120.0, 1.0) var distancia_vertical: float = 44.0:
	set(value):
		distancia_vertical = value
		if is_node_ready():
			position.y = distancia_vertical

@export_range(0.1, 10.0, 0.1) var duracao_visibilidade: float = 2.0
@export var health_component_path: NodePath = NodePath("../HealthComponent")

@onready var preenchimento: TextureRect = $Preenchimento
@onready var temporizador: Timer = $Temporizador

var health_component: Node
var em_combate: bool = false
var ja_foi_exibida: bool = false


func _ready() -> void:
	health_component = get_node(health_component_path)

	health_component.connect(&"health_changed", _on_health_changed)
	health_component.connect(&"died", hide_immediately)
	temporizador.timeout.connect(hide)

	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	scale = Vector2.ONE * escala_visual

	# A barra é um filho direto do inimigo, então x=0 a mantém
	# rigorosamente centralizada no inimigo.
	position = Vector2(0.0, distancia_vertical)

	_atualizar_preenchimento(
		int(health_component.get(&"current_hp")),
		int(health_component.get(&"max_hp"))
	)

	hide()


func set_in_combat(ativo: bool) -> void:
	em_combate = ativo

	if em_combate:
		temporizador.stop()
	elif ja_foi_exibida and visible:
		temporizador.start(duracao_visibilidade)


func hide_immediately() -> void:
	temporizador.stop()
	hide()


func _on_health_changed(vida_atual: int, vida_maxima: int) -> void:
	_atualizar_preenchimento(vida_atual, vida_maxima)

	if vida_atual <= 0:
		hide_immediately()
		return

	ja_foi_exibida = true
	show()

	if em_combate:
		temporizador.stop()
	else:
		temporizador.start(duracao_visibilidade)


func _atualizar_preenchimento(vida_atual: int, vida_maxima: int) -> void:
	var proporcao := clampf(
		float(vida_atual) / maxf(1.0, float(vida_maxima)),
		0.0,
		1.0
	)

	# small_bar_fill.png tem uma faixa útil de 64x3.
	# O fill é colocado POR CIMA do centro da base, pois o centro
	# do small_bar_base.png possui pixels opacos no interior.
	var largura := LARGURA_CENTRO * proporcao

	preenchimento.position = Vector2(-LARGURA_CENTRO * 0.5, 8.0)
	preenchimento.size = Vector2(largura, 3.0)
	preenchimento.visible = largura > 0.0
