extends CharacterBody2D

signal death_effect_finished

const TEXTURA_POEIRA := preload("res://assets/Particle/dust1.png")
const TEXTURA_OSSOS := preload("res://assets/Decoration/bones_3.png")

@export var velocidade_corrida: float = 180.0
@export var distancia_ataque: float = 78.0
@export var tempo_entre_ataques: float = 0.9

const VELOCIDADE_POEIRA := 10.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_deteccao: Area2D = $AreaDeteccao
@onready var health_component: Node = $HealthComponent
@onready var barra_vida: Node = $EnemyHealthBar

var alvo: CharacterBody2D = null
var tempo_ataque_restante: float = 0.0
var ataque_atual_aplicou_dano: bool = false
var is_dead: bool = false


func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	sprite.play("idle")

	area_deteccao.body_entered.connect(_on_area_body_entered)
	area_deteccao.body_exited.connect(_on_area_body_exited)
	sprite.frame_changed.connect(_on_sprite_frame_changed)
	health_component.connect(&"died", _on_health_died)


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if tempo_ataque_restante > 0.0:
		tempo_ataque_restante = maxf(0.0, tempo_ataque_restante - delta)

	if not is_instance_valid(alvo):
		alvo = null
	barra_vida.call(&"set_in_combat", alvo != null)

	if alvo == null:
		velocity = Vector2.ZERO
		_reproduzir_se_diferente(&"idle")
		move_and_slide()
		return

	var distancia := global_position.distance_to(alvo.global_position)

	if distancia <= distancia_ataque:
		# Dentro do alcance: para e fica virado para o Sapudo.
		velocity = Vector2.ZERO
		flip_sprite_na_direcao_do_alvo()

		# Se um ataque já está em execução, não o interrompe.
		if sprite.animation == &"attack" and sprite.is_playing():
			pass
		# Quando o cooldown termina, inicia um novo ataque,
		# mesmo que a animação anterior tenha sido "run".
		elif tempo_ataque_restante <= 0.0:
			sprite.play(&"attack")
			tempo_ataque_restante = tempo_entre_ataques
			ataque_atual_aplicou_dano = false
		else:
			_reproduzir_se_diferente(&"idle")
	else:
		# Fora do alcance: corre em direção ao Sapudo.
		var direcao := global_position.direction_to(alvo.global_position)
		velocity = direcao * velocidade_corrida
		flip_sprite_na_direcao_do_alvo()
		_reproduzir_se_diferente(&"run")

	move_and_slide()


func _on_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("sapudo") and body is CharacterBody2D:
		alvo = body


func _on_area_body_exited(body: Node2D) -> void:
	if body == alvo:
		alvo = null


func take_damage(amount: int) -> void:
	health_component.call(&"take_damage", amount)


func _on_health_died() -> void:
	is_dead = true
	alvo = null
	velocity = Vector2.ZERO
	sprite.stop()
	sprite.hide()
	collision_layer = 0
	collision_mask = 0
	area_deteccao.monitoring = false
	barra_vida.call(&"hide_immediately")
	_iniciar_fluxo_morte()


func _iniciar_fluxo_morte() -> void:
	var poeira := AnimatedSprite2D.new()
	var frames := SpriteFrames.new()
	frames.add_animation(&"desaparecer")
	frames.set_animation_loop(&"desaparecer", false)
	frames.set_animation_speed(&"desaparecer", VELOCIDADE_POEIRA)

	for indice in 8:
		var quadro := AtlasTexture.new()
		quadro.atlas = TEXTURA_POEIRA
		quadro.region = Rect2(indice * 64, 0, 64, 64)
		frames.add_frame(&"desaparecer", quadro)

	poeira.sprite_frames = frames
	poeira.scale = Vector2(1.5, 1.5)
	add_child(poeira)

	var ossos := Sprite2D.new()
	ossos.texture = TEXTURA_OSSOS
	ossos.position = Vector2(0, -48)
	add_child(ossos)

	var queda := create_tween()
	queda.tween_property(ossos, "position:y", _obter_posicao_final_dos_ossos(), 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	poeira.animation_finished.connect(_ao_efeito_de_morte_terminar)
	poeira.play(&"desaparecer")


func _ao_efeito_de_morte_terminar() -> void:
	death_effect_finished.emit()
	queue_free()


func _obter_posicao_final_dos_ossos() -> float:
	var capsula := $CollisionShape2D.shape as CapsuleShape2D
	if capsula == null:
		return 0.0

	return $CollisionShape2D.position.y + capsula.height * 0.5 - TEXTURA_OSSOS.get_height() * 0.5


func _on_sprite_frame_changed() -> void:
	if sprite.animation != &"attack" or ataque_atual_aplicou_dano:
		return

	var quadro_de_impacto := sprite.sprite_frames.get_frame_count(&"attack") / 2
	if sprite.frame < quadro_de_impacto:
		return

	ataque_atual_aplicou_dano = true
	if is_instance_valid(alvo) and global_position.distance_to(alvo.global_position) <= distancia_ataque:
		if alvo.has_method(&"take_damage"):
			alvo.call(&"take_damage", 1, global_position)


func flip_sprite_na_direcao_do_alvo() -> void:
	if alvo == null:
		return

	var delta_x := alvo.global_position.x - global_position.x

	if absf(delta_x) > 1.0:
		# O spritesheet do Goblin está orientado para a direita.
		sprite.flip_h = delta_x < 0.0


func _reproduzir_se_diferente(nome_animacao: StringName) -> void:
	if sprite.animation != nome_animacao:
		sprite.play(nome_animacao)
