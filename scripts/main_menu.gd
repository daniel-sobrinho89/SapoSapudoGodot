extends Control

@onready var lista_fases: VBoxContainer = $Central/Cartao/Margem/Conteudo/ListaFases
@onready var botao_carregar: Button = $Central/Cartao/Margem/Conteudo/CarregarJogo


func _ready() -> void:
	_atualizar_lista_fases()
	lista_fases.hide()


func _on_novo_jogo_pressed() -> void:
	Progression.iniciar_novo_jogo()


func _on_carregar_jogo_pressed() -> void:
	lista_fases.visible = not lista_fases.visible
	if lista_fases.visible:
		_atualizar_lista_fases()


func _atualizar_lista_fases() -> void:
	for filho in lista_fases.get_children():
		filho.queue_free()

	for fase in Progression.fases_liberadas:
		var botao := Button.new()
		botao.text = "FASE %d" % fase
		botao.custom_minimum_size = Vector2(280, 44)
		botao.pressed.connect(Progression.iniciar_fase.bind(fase))
		lista_fases.add_child(botao)

	botao_carregar.disabled = Progression.fases_liberadas.is_empty()
