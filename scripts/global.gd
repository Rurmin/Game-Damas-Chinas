extends Node

var num_jugadores : int = 2
var musica_silenciada : bool = false
var tiempo_turno_idx : int = 3 # 0: 15s, 1: 30s, 2: 60s, 3: Sin límite
var mapa_seleccionado : int = 0 # 0: Atardecer, 1: Noche Mística
var monedas_jugadores = {}

func _ready():
	actualizar_audio_global()

func inicializar_monedas(num_activos: int):
	monedas_jugadores.clear()
	for i in range(num_activos):
		monedas_jugadores[i] = 0

func actualizar_audio_global():
	var bus_idx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(bus_idx, musica_silenciada)