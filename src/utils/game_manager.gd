extends Node

# Configurações de áudio
@export var master_volume: float = 0.8
@export var music_volume: float = 0.6
@export var sfx_volume: float = 0.8

# Configurações de gameplay
@export var difficulty: String = "normal"  # easy, normal, hard
@export var auto_save_interval: float = 300.0  # 5 minutos

# Arquivo de save
const SAVE_PATH = "user://tibia_rpg_save.json"

func _ready() -> void:
	# Carrega configurações
	load_settings()
	
	# Setup de áudio
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
	set_bus_volume("Master", master_volume)
	set_bus_volume("Music", music_volume)
	set_bus_volume("SFX", sfx_volume)
	
	print("GameManager iniciado!")

func save_game(player_data: Dictionary) -> void:
	var save_data = {
		"player": player_data,
		"timestamp": Time.get_ticks_msec(),
		"difficulty": difficulty
	}
	
	var json = JSON.stringify(save_data)
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	
	if file:
		file.store_string(json)
		print("Game salvo em: %s" % SAVE_PATH)
	else:
		print("Erro ao salvar game!")

func load_game() -> Dictionary:
	if ResourceLoader.exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			var json = JSON.new()
			if json.parse(json_string) == OK:
				print("Game carregado!")
				return json.data
	
	print("Nenhum save encontrado!")
	return {}

func save_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("gameplay", "difficulty", difficulty)
	config.save("user://settings.cfg")

func load_settings() -> void:
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		master_volume = config.get_value("audio", "master_volume", 0.8)
		music_volume = config.get_value("audio", "music_volume", 0.6)
		sfx_volume = config.get_value("audio", "sfx_volume", 0.8)
		difficulty = config.get_value("gameplay", "difficulty", "normal")

func set_bus_volume(bus_name: String, volume: float) -> void:
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index >= 0:
		AudioServer.set_bus_volume_db(bus_index, linear2db(volume))

func play_sfx(sfx_path: String, volume: float = 1.0) -> void:
	var audio_player = AudioStreamPlayer.new()
	audio_player.bus = "SFX"
	audio_player.volume_db = linear2db(volume)
	add_child(audio_player)
	
	var audio_stream = load(sfx_path)
	if audio_stream:
		audio_player.stream = audio_stream
		audio_player.play()
		await audio_player.finished
		audio_player.queue_free()
