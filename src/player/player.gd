extends CharacterBody2D

# Movimento
@export var speed: float = 200.0
@export var acceleration: float = 1500.0
@export var friction: float = 1200.0

# Stats do personagem
@export var max_hp: int = 100
@export var current_hp: int = 100
@export var attack_power: int = 15
@export var defense: int = 5
@export var attack_speed: float = 1.0  # Ataques por segundo

# Referências
var animation_player: AnimationPlayer
var attack_timer: Timer
var direction: Vector2 = Vector2.ZERO
var can_attack: bool = true
var target_enemy: Node2D = null

func _ready() -> void:
	add_to_group("player")
	animation_player = $AnimationPlayer
	attack_timer = $AttackTimer
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	attack_timer.wait_time = 1.0 / attack_speed
	
	# Inicializa HP
	current_hp = max_hp
	
	print("Player iniciado com HP: %d" % current_hp)

func _physics_process(delta: float) -> void:
	# Movimento
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if input_direction != Vector2.ZERO:
		direction = input_direction.normalized()
		velocity = velocity.move_toward(direction * speed, acceleration * delta)
		_play_walk_animation(direction)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		_play_idle_animation()
	
	move_and_slide()
	
	# Procura inimigo mais próximo
	_find_nearest_enemy()
	
	# Ataca automaticamente se tiver alvo
	if target_enemy and can_attack:
		attack_enemy(target_enemy)

func _find_nearest_enemy() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var nearest_distance = 150.0  # Range de ataque
	target_enemy = null
	
	for enemy in enemies:
		var distance = global_position.distance_to(enemy.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			target_enemy = enemy

func attack_enemy(enemy: Node2D) -> void:
	if enemy == null or not is_instance_valid(enemy):
		target_enemy = null
		return
	
	can_attack = false
	attack_timer.start()
	
	# Calcula dano com variação aleatória
	var base_damage = attack_power
	var damage_variance = randi_range(-3, 5)
	var final_damage = max(1, base_damage + damage_variance)
	
	# Aplica defesa do inimigo
	var enemy_defense = enemy.defense if hasattr(enemy, "defense") else 0
	final_damage = max(1, final_damage - enemy_defense)
	
	# Inflige dano
	if hasattr(enemy, "take_damage"):
		enemy.take_damage(final_damage)
	
	print("Player atacou %s por %d de dano!" % [enemy.name, final_damage])

func take_damage(damage: int) -> void:
	current_hp = max(0, current_hp - damage)
	print("Player recebeu %d de dano! HP: %d/%d" % [damage, current_hp, max_hp])
	
	if current_hp <= 0:
		die()

func die() -> void:
	print("Player morreu!")
	# TODO: Implementar lógica de morte (respawn, game over, etc)

func heal(amount: int) -> void:
	current_hp = min(max_hp, current_hp + amount)
	print("Player curado! HP: %d/%d" % [current_hp, max_hp])

func _play_walk_animation(direction: Vector2) -> void:
	var anim = "walk"
	if direction.y > 0:
		anim = "walk_down"
	elif direction.y < 0:
		anim = "walk_up"
	elif direction.x > 0:
		anim = "walk_right"
	elif direction.x < 0:
		anim = "walk_left"
	
	if animation_player.current_animation != anim:
		animation_player.play(anim)

func _play_idle_animation() -> void:
	if animation_player.current_animation != "idle":
		animation_player.play("idle")

func _on_attack_timer_timeout() -> void:
	can_attack = true
