extends CharacterBody2D

# Tipos de inimigos
enum ENEMY_TYPE { RAT, GOBLIN, SPIDER, ORC }

# Stats base por tipo
const ENEMY_STATS = {
	ENEMY_TYPE.RAT: {
		"name": "Rato",
		"max_hp": 10,
		"attack": 3,
		"defense": 1,
		"speed": 80,
		"attack_speed": 0.8,
		"exp_reward": 10
	},
	ENEMY_TYPE.GOBLIN: {
		"name": "Goblin",
		"max_hp": 25,
		"attack": 8,
		"defense": 2,
		"speed": 100,
		"attack_speed": 1.0,
		"exp_reward": 30
	},
	ENEMY_TYPE.SPIDER: {
		"name": "Aranha",
		"max_hp": 20,
		"attack": 6,
		"defense": 1,
		"speed": 120,
		"attack_speed": 1.2,
		"exp_reward": 25
	},
	ENEMY_TYPE.ORC: {
		"name": "Orc",
		"max_hp": 50,
		"attack": 15,
		"defense": 5,
		"speed": 90,
		"attack_speed": 0.7,
		"exp_reward": 60
	}
}

# Variáveis do inimigo
var enemy_type: ENEMY_TYPE = ENEMY_TYPE.RAT
var max_hp: int = 10
var current_hp: int = 10
var attack: int = 3
var defense: int = 1
var speed: float = 80.0
var attack_speed: float = 0.8
var exp_reward: int = 10
var enemy_name: String = "Rato"

# Comportamento
var player: Node2D = null
var target: Node2D = null
var detection_range: float = 300.0
var attack_range: float = 50.0
var velocity: Vector2 = Vector2.ZERO
var can_attack: bool = true
var attack_timer: Timer
var animation_player: AnimationPlayer
var alive: bool = true

func _ready() -> void:
	add_to_group("enemies")
	animation_player = $AnimationPlayer
	attack_timer = $AttackTimer
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	
	# Busca o jogador
	player = get_tree().get_first_node_in_group("player")
	
	print("%s criado com HP: %d" % [enemy_name, current_hp])

func _physics_process(delta: float) -> void:
	if not alive:
		return
	
	# Verifica se pode ver o player
	if player and is_instance_valid(player):
		var distance_to_player = global_position.distance_to(player.global_position)
		
		if distance_to_player < detection_range:
			target = player
		else:
			target = null
	
	# Comportamento baseado no alvo
	if target and is_instance_valid(target):
		var distance_to_target = global_position.distance_to(target.global_position)
		
		if distance_to_target > attack_range:
			# Move em direção ao alvo
			var direction = (target.global_position - global_position).normalized()
			velocity = direction * speed
			_play_walk_animation(direction)
		else:
			# Ataca o alvo
			velocity = Vector2.ZERO
			_play_idle_animation()
			
			if can_attack:
				attack_target(target)
	else:
		# Sem alvo, para de se mover
		velocity = Vector2.ZERO
		_play_idle_animation()
	
	move_and_slide()

func attack_target(target_node: Node2D) -> void:
	if target_node == null or not is_instance_valid(target_node):
		return
	
	can_attack = false
	attack_timer.wait_time = 1.0 / attack_speed
	attack_timer.start()
	
	# Calcula dano
	var base_damage = attack
	var damage_variance = randi_range(-2, 3)
	var final_damage = max(1, base_damage + damage_variance)
	
	# Aplica defesa do alvo
	var target_defense = target_node.defense if hasattr(target_node, "defense") else 0
	final_damage = max(1, final_damage - target_defense)
	
	# Inflige dano
	if hasattr(target_node, "take_damage"):
		target_node.take_damage(final_damage)
	
	print("%s atacou por %d de dano!" % [enemy_name, final_damage])

func take_damage(damage: int) -> void:
	current_hp = max(0, current_hp - damage)
	print("%s recebeu %d de dano! HP: %d/%d" % [enemy_name, damage, current_hp, max_hp])
	
	if current_hp <= 0:
		die()

func die() -> void:
	print("%s morreu! Concedeu %d de EXP" % [enemy_name, exp_reward])
	alive = false
	
	# TODO: Animar morte
	# TODO: Dar EXP ao player
	# TODO: Droppar items
	
	await get_tree().create_timer(0.5).timeout
	queue_free()

func setup_enemy(type: ENEMY_TYPE) -> void:
	enemy_type = type
	var stats = ENEMY_STATS[type]
	
	enemy_name = stats["name"]
	max_hp = stats["max_hp"]
	current_hp = max_hp
	attack = stats["attack"]
	defense = stats["defense"]
	speed = stats["speed"]
	attack_speed = stats["attack_speed"]
	exp_reward = stats["exp_reward"]

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
