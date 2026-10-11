extends Control

# Referencias a nodos de la interfaz principal
@onready var ventana_reglas = $VentanaReglas
@onready var ventana_ajustes = $VentanaAjustes
@onready var boton_jugar = $ContenedorBotones/BotonJugar
@onready var boton_como_jugar = $ContenedorBotones/BotonComoJugar
@onready var boton_opciones = $ContenedorBotones/BotonOpciones
@onready var boton_cerrar_reglas = $VentanaReglas/BotonCerrar
@onready var boton_musica = $BotonMusica
@onready var musica_fondo = $MusicaFondo

# Referencias a nodos de la Ventana de Ajustes (ajustados a tu captura)
@onready var boton_cerrar_ajustes = $VentanaAjustes/CerrarAjustes
@onready var slider_volumen = $VentanaAjustes/SliderVolumen
@onready var option_modo = $VentanaAjustes/OptionMode
@onready var option_tiempo = $VentanaAjustes/OptionTiempo
@onready var boton_creditos = $VentanaAjustes/BotonCreditos

var musica_activada : bool = true

func _ready():
	# 1. Ocultar ventanas emergentes al iniciar
	if ventana_reglas: 
		ventana_reglas.hide()
	if ventana_ajustes: 
		ventana_ajustes.hide()
	
	# 2. Conectar botones principales del menú
	if boton_jugar: 
		boton_jugar.pressed.connect(_on_boton_jugar_pressed)
	if boton_como_jugar: 
		boton_como_jugar.pressed.connect(_on_boton_como_jugar_pressed)
	if boton_opciones: 
		boton_opciones.pressed.connect(_on_boton_opciones_pressed)
	if boton_cerrar_reglas: 
		boton_cerrar_reglas.pressed.connect(_on_boton_cerrar_reglas_pressed)
	if boton_musica: 
		boton_musica.pressed.connect(_on_boton_musica_pressed)
	
	# 3. Conectar acciones de la Ventana de Ajustes
	if boton_cerrar_ajustes: 
		boton_cerrar_ajustes.pressed.connect(_on_boton_cerrar_ajustes_pressed)
	if boton_creditos: 
		boton_creditos.pressed.connect(_on_boton_creditos_pressed)
	
	# Configurar Slider de Volumen (Música)
	# Configurar Slider de Volumen (Música)
	if slider_volumen:
		slider_volumen.min_value = 0.0001
		slider_volumen.max_value = 1.0
		slider_volumen.step = 0.01
		slider_volumen.value = 0.8
		slider_volumen.value_changed.connect(Callable(self, "_on_slider_volumen_value_changed"))
		
	# Configurar opciones de Modo de Juego
	if option_modo:
		option_modo.clear()
		option_modo.add_item("1 vs 1 (2 Jugadores)")
		option_modo.add_item("3 Jugadores")
		option_modo.add_item("4 Jugadores")
		option_modo.add_item("6 Jugadores")
		option_modo.add_item("vs Inteligencia Artificial")

	# Configurar opciones de Tiempo por Turno
	if option_tiempo:
		option_tiempo.clear()
		option_tiempo.add_item("15 segundos")
		option_tiempo.add_item("30 segundos")
		option_tiempo.add_item("60 segundos")
		option_tiempo.add_item("Sin Límite")

# --- ACCIONES Y SEÑALES ---

func _on_boton_jugar_pressed():
	get_tree().change_scene_to_file("res://scenes/tablero.tscn")

func _on_boton_como_jugar_pressed():
	if ventana_ajustes: ventana_ajustes.hide()
	if ventana_reglas: ventana_reglas.show()

func _on_boton_cerrar_reglas_pressed():
	if ventana_reglas: ventana_reglas.hide()

func _on_boton_opciones_pressed():
	if ventana_reglas: ventana_reglas.hide()
	if ventana_ajustes: ventana_ajustes.show()

func _on_boton_cerrar_ajustes_pressed():
	if ventana_ajustes: ventana_ajustes.hide()

func _on_boton_musica_pressed():
	musica_activada = !musica_activada
	if musica_fondo:
		musica_fondo.stream_paused = !musica_activada

func _on_slider_volumen_value_changed(value: float) -> void:
	var bus_idx = AudioServer.get_bus_index("Master")
	if value <= 0.01:
		AudioServer.set_bus_mute(bus_idx, true)
	else:
		AudioServer.set_bus_mute(bus_idx, false)
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))
		
func _on_boton_creditos_pressed():
	print("Desarrollado por el equipo de Damas Chinas")
