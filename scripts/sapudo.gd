extends CharacterBody2D
class_name Sapudo

@export var velocidade: float = 220.0
@export var max_hp: int = 6
@export var distancia_ataque: float = 78.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var poeira: AnimatedSprite2D = $Poeira
@onready var ossos: Sprite2D = $Ossos
@onready var colisao: CollisionShape2D = $CollisionShape2D

signal health_changed(current_health: int, maximum_health: int)
signal died

var current_hp: int
var is_dead: bool = false
var ataque_atual_aplicou_dano: bool = false


func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	max_hp = Progression.obter_vida_maxima_sapudo()
	current_hp = max_hp
	sprite.play("idle")
	poeira.animation_finished.connect(_on_poeira_animation_finished)
	sprite.frame_changed.connect(_on_sprite_frame_changed)
	health_changed.emit(current_hp, max_hp)


func _physics_process(_delta: float) -> void:
	if is_dead:
		velocity = Vector2.ZERO
		return

	if sprite.animation == &"attack" and sprite.is_playing():
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var direcao := Vector2.ZERO

	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		direcao.x -= 1.0

	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		direcao.x += 1.0

	if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
		direcao.y -= 1.0

	if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
		direcao.y += 1.0

	if direcao.length_squared() > 1.0:
		direcao = direcao.normalized()

	# O spritesheet do Sapudo está orientado para a direita.
	# Ao andar para a esquerda, espelhamos horizontalmente.
	if absf(direcao.x) > 0.0:
		sprite.flip_h = direcao.x < 0.0

	if Input.is_action_just_pressed(&"ui_accept"):
		velocity = Vector2.ZERO
		sprite.play(&"attack")
		ataque_atual_aplicou_dano = false
		move_and_slide()
		return

	if Input.is_key_pressed(KEY_SHIFT):
		velocity = Vector2.ZERO
		sprite.play(&"guard")
		move_and_slide()
		return

	velocity = direcao * velocidade
	if direcao == Vector2.ZERO:
		sprite.play(&"idle")
	else:
		sprite.play(&"run")
	move_and_slide()


func heal(amount: int) -> void:
	if is_dead or amount <= 0 or current_hp >= max_hp:
		return

	current_hp = mini(max_hp, current_hp + amount)
	health_changed.emit(current_hp, max_hp)


func collect_health_pickup(amount: int) -> void:
	if is_dead or amount <= 0:
		return
	heal(amount)


func take_damage(amount: int, attacker_position: Vector2 = Vector2.INF) -> void:
	if is_dead or amount <= 0:
		return
	if attacker_position.is_finite() and _esta_defendendo_contra(attacker_position):
		return

	current_hp = maxi(0, current_hp - amount)
	health_changed.emit(current_hp, max_hp)

	if current_hp == 0:
		_morrer()


func _morrer() -> void:
	if is_dead:
		return

	is_dead = true
	velocity = Vector2.ZERO
	sprite.hide()
	collision_layer = 0
	collision_mask = 0
	poeira.show()
	poeira.play(&"desaparecer")
	_iniciar_queda_dos_ossos()
	died.emit()


func _on_sprite_frame_changed() -> void:
	if sprite.animation != &"attack" or ataque_atual_aplicou_dano:
		return

	var quadro_de_impacto := sprite.sprite_frames.get_frame_count(&"attack") / 2
	if sprite.frame < quadro_de_impacto:
		return

	ataque_atual_aplicou_dano = true
	var inimigo := _obter_inimigo_no_alcance()
	if inimigo != null and inimigo.has_method(&"take_damage"):
		inimigo.call(&"take_damage", Progression.obter_dano_ataque_sapudo())


func _on_poeira_animation_finished() -> void:
	poeira.hide()


func _iniciar_queda_dos_ossos() -> void:
	ossos.position = Vector2(0, -48)
	ossos.show()
	var queda := create_tween()
	queda.tween_property(ossos, "position:y", _obter_posicao_final_dos_ossos(), 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _esta_defendendo_contra(attacker_position: Vector2) -> bool:
	var animacao_de_defesa_ativa := sprite.animation == &"guard" and sprite.is_playing()
	if not animacao_de_defesa_ativa and not Input.is_key_pressed(KEY_SHIFT):
		return false

	var direcao_atacante := global_position.direction_to(attacker_position)
	if direcao_atacante == Vector2.ZERO:
		return false

	var direcao_olhar := Vector2.LEFT if sprite.flip_h else Vector2.RIGHT
	return direcao_olhar.dot(direcao_atacante) > 0.0


func _obter_posicao_final_dos_ossos() -> float:
	var capsula := colisao.shape as CapsuleShape2D
	if capsula == null:
		return 0.0

	return colisao.position.y + capsula.height * 0.5 - ossos.texture.get_height() * 0.5


func _obter_inimigo_no_alcance() -> Node2D:
	var inimigo_mais_proximo: Node2D = null
	var menor_distancia := distancia_ataque

	for candidato in get_tree().get_nodes_in_group(&"inimigos"):
		if candidato is Node2D and candidato.has_method(&"take_damage"):
			var inimigo := candidato as Node2D
			var distancia := global_position.distance_to(inimigo.global_position)
			if distancia <= menor_distancia:
				inimigo_mais_proximo = inimigo
				menor_distancia = distancia

	return inimigo_mais_proximo
