extends Node2D

# Tamanho dos chunks (em pixels)
const CHUNK_SIZE: int = 256

# Referências
var player: Node2D = null
var active_chunks: Dictionary = {}  # Dicionário de chunks carregados: Vector2i -> Chunk
var enemy_scene: PackedScene = null

# Configurações de geração
var spawn_rate: float = 0.5  # Chance de spawnar inimigo por chunk
var max_enemies_per_chunk: int = 3
var chunk_load_distance: int = 3  # Chunks de distância para carregar

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	enemy_scene = preload("res://scenes/enemy.tscn")
	
	# Carrega primeiro chunk
	if player:
		_update_chunks()
	
	print("WorldGenerator iniciado!")

func _process(delta: float) -> void:
	if player:
		_update_chunks()

func _update_chunks() -> void:
	# Calcula o chunk atual do player
	var player_chunk = _get_chunk_coords(player.global_position)
	
	# Carrega chunks próximos
	for x in range(player_chunk.x - chunk_load_distance, player_chunk.x + chunk_load_distance + 1):
		for y in range(player_chunk.y - chunk_load_distance, player_chunk.y + chunk_load_distance + 1):
			var chunk_coords = Vector2i(x, y)
			if not chunk_coords in active_chunks:
				_load_chunk(chunk_coords)
	
	# Descarrega chunks distantes
	var chunks_to_unload = []
	for chunk_coords in active_chunks.keys():
		var distance = chunk_coords.distance_to(player_chunk)
		if distance > chunk_load_distance + 1:
			chunks_to_unload.append(chunk_coords)
	
	for chunk_coords in chunks_to_unload:
		_unload_chunk(chunk_coords)

func _get_chunk_coords(position: Vector2) -> Vector2i:
	return Vector2i(
		int(position.x) / CHUNK_SIZE,
		int(position.y) / CHUNK_SIZE
	)

func _load_chunk(chunk_coords: Vector2i) -> void:
	print("Carregando chunk: %s" % chunk_coords)
	
	# Cria container para o chunk
	var chunk_container = Node2D.new()
	chunk_container.name = "Chunk_%d_%d" % [chunk_coords.x, chunk_coords.y]
	add_child(chunk_container)
	
	active_chunks[chunk_coords] = chunk_container
	
	# Gera inimigos neste chunk
	_spawn_enemies_in_chunk(chunk_coords, chunk_container)

func _unload_chunk(chunk_coords: Vector2i) -> void:
	print("Descarregando chunk: %s" % chunk_coords)
	
	if chunk_coords in active_chunks:
		var chunk = active_chunks[chunk_coords]
		chunk.queue_free()
		active_chunks.erase(chunk_coords)

func _spawn_enemies_in_chunk(chunk_coords: Vector2i, container: Node2D) -> void:
	# Gera quantidade aleatória de inimigos
	var enemy_count = randi_range(0, max_enemies_per_chunk)
	
	for i in range(enemy_count):
		# Chance de spawnar
		if randf() > spawn_rate:
			continue
		
		# Posição aleatória dentro do chunk
		var local_x = randi_range(32, CHUNK_SIZE - 32)
		var local_y = randi_range(32, CHUNK_SIZE - 32)
		
		var world_pos = Vector2(
			chunk_coords.x * CHUNK_SIZE + local_x,
			chunk_coords.y * CHUNK_SIZE + local_y
		)
		
		# Escolhe tipo de inimigo aleatório
		var enemy_types = [0, 1, 2, 3]  # RAT, GOBLIN, SPIDER, ORC
		var random_type = enemy_types[randi() % enemy_types.size()]
		
		# Cria inimigo
		var enemy = enemy_scene.instantiate()
		enemy.global_position = world_pos
		enemy.setup_enemy(random_type)
		container.add_child(enemy)
		
		print("Inimigo %s spawnado em %s" % [enemy.enemy_name, world_pos])

# Retorna todos os inimigos ativos
func get_active_enemies() -> Array:
	var enemies = []
	for chunk in active_chunks.values():
		enemies.append_array(chunk.get_children())
	return enemies