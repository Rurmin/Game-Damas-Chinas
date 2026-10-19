extends Control

@onready var ventana_reglas = $VentanaReglas
@onready var ventana_ajustes = $VentanaAjustes
@onready var boton_jugar = $ContenedorBotones/BotonJugar
@onready var boton_como_jugar = $ContenedorBotones/BotonComoJugar
@onready var boton_opciones = $ContenedorBotones/BotonOpciones
@onready var boton_cerrar_reglas = $VentanaReglas/BotonCerrar
@onready var musica_fondo = $MusicaFondo
@onready var boton_salir = $BotonMusica

@onready var boton_cerrar_ajustes = $VentanaAjustes/CerrarAjustes
@onready var titulo_ajustes = $VentanaAjustes/TituloAjustes
@onready var slider_volumen = $VentanaAjustes/SliderVolumen
@onready var option_modo = $VentanaAjustes/OptionModo
@onready var option_tiempo = $VentanaAjustes/OptionTiempo
@onready var boton_creditos = $VentanaAjustes/BotonCreditos
@onready var label_volumen = $VentanaAjustes/LabelVolumen
@onready var modo_juego_label = $VentanaAjustes/MododeJuego
@onready var label_tiempo = $VentanaAjustes/LabelTiempo

var tex_titulo_ajustes = preload("res://assets/titulo_ajustes.png")
var tex_titulo_audio = preload("res://assets/titulo_audio.png")

var boton_comenzar_partida : Button = null
var check_audio_arriba : CheckBox = null
var label_info_creditos : Label = null

# Referencias para selección de mapa
var label_mapa : Label = null
var option_mapa : OptionButton = null

func _ready():
	if ventana_reglas: ventana_reglas.hide()
	if ventana_ajustes: ventana_ajustes.hide()
	
	if boton_jugar:
		boton_jugar.text = "JUGAR"
		boton_jugar.pressed.connect(_on_boton_jugar_pressed)
	if boton_como_jugar:
		boton_como_jugar.text = "CÓMO JUGAR"
		boton_como_jugar.pressed.connect(_on_boton_como_jugar_pressed)
	if boton_opciones:
		boton_opciones.text = "SONIDO"
		boton_opciones.pressed.connect(_on_boton_opciones_pressed)
	
	if boton_cerrar_reglas: boton_cerrar_reglas.pressed.connect(_on_boton_cerrar_reglas_pressed)
	if boton_cerrar_ajustes: boton_cerrar_ajustes.pressed.connect(_on_boton_cerrar_ajustes_pressed)
	if boton_creditos:
		boton_creditos.text = "Créditos"
		boton_creditos.pressed.connect(_on_boton_creditos_pressed)
	if boton_salir: boton_salir.pressed.connect(func(): get_tree().quit())
	
	var bus_idx = AudioServer.get_bus_index("Master")
	var volumen_actual = db_to_linear(AudioServer.get_bus_volume_db(bus_idx))
	var esta_silenciado = AudioServer.is_bus_mute(bus_idx)
	
	if label_volumen:
		label_volumen.text = "Volumen General:"
		label_volumen.add_theme_color_override("font_color", Color(0.18, 0.09, 0.04, 1))
	if modo_juego_label:
		modo_juego_label.text = "Modo de Juego:"
		modo_juego_label.add_theme_color_override("font_color", Color(0.18, 0.09, 0.04, 1))
	if label_tiempo:
		label_tiempo.text = "Tiempo por Turno:"
		label_tiempo.add_theme_color_override("font_color", Color(0.18, 0.09, 0.04, 1))
	
	if slider_volumen:
		slider_volumen.min_value = 0.0001
		slider_volumen.max_value = 1.0
		slider_volumen.step = 0.01
		slider_volumen.value = volumen_actual 
		slider_volumen.value_changed.connect(Callable(self, "_on_slider_volumen_value_changed"))
		
	if option_modo:
		option_modo.clear()
		option_modo.custom_minimum_size = Vector2(220, 35)
		option_modo.add_item("1 vs 1 (2 Jugadores)")
		option_modo.add_item("3 Jugadores")
		option_modo.add_item("4 Jugadores")
		option_modo.add_item("6 Jugadores")

	if option_tiempo:
		option_tiempo.clear()
		option_tiempo.custom_minimum_size = Vector2(220, 35)
		option_tiempo.add_item("15 Segundos")
		option_tiempo.add_item("30 Segundos")
		option_tiempo.add_item("60 Segundos")
		option_tiempo.add_item("Sin Límite")
		option_tiempo.selected = Global.tiempo_turno_idx
		
	if ventana_ajustes:
		# Botón Comenzar
		boton_comenzar_partida = Button.new()
		boton_comenzar_partida.text = "¡COMENZAR PARTIDA!"
		boton_comenzar_partida.custom_minimum_size = Vector2(240, 46)
		boton_comenzar_partida.position = Vector2(130, 425)
		boton_comenzar_partida.add_theme_font_size_override("font_size", 18)
		boton_comenzar_partida.pressed.connect(_on_boton_comenzar_partida_pressed)
		ventana_ajustes.add_child(boton_comenzar_partida)
		
		# Checkbox Audio
		check_audio_arriba = CheckBox.new()
		check_audio_arriba.text = "Silenciar Todo el Audio"
		check_audio_arriba.position = Vector2(140, 265)
		check_audio_arriba.add_theme_font_size_override("font_size", 19)
		check_audio_arriba.add_theme_color_override("font_color", Color(0.18, 0.09, 0.04, 1))
		check_audio_arriba.add_theme_color_override("font_pressed_color", Color(0.18, 0.09, 0.04, 1))
		check_audio_arriba.add_theme_color_override("font_hover_color", Color(0.3, 0.15, 0.05, 1))
		check_audio_arriba.button_pressed = esta_silenciado 
		check_audio_arriba.toggled.connect(_on_audio_arriba_toggled)
		ventana_ajustes.add_child(check_audio_arriba)

		# Etiqueta de Créditos informativa en el panel de Audio
		label_info_creditos = Label.new()
		label_info_creditos.text = "Desarrollado por el Equipo de Damas Chinas\nEdición Especial — Unidad III y Cultura General"
		label_info_creditos.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label_info_creditos.position = Vector2(40, 340)
		label_info_creditos.custom_minimum_size = Vector2(420, 60)
		label_info_creditos.add_theme_font_size_override("font_size", 16)
		label_info_creditos.add_theme_color_override("font_color", Color(0.22, 0.11, 0.04, 1))
		label_info_creditos.hide()
		ventana_ajustes.add_child(label_info_creditos)

		# Texto de Selección de Mapa (y=340)
		label_mapa = Label.new()
		label_mapa.text = "Escenario / Mapa:"
		label_mapa.position = Vector2(40, 340)
		label_mapa.add_theme_font_size_override("font_size", 20)
		label_mapa.add_theme_color_override("font_color", Color(0.18, 0.09, 0.04, 1))
		ventana_ajustes.add_child(label_mapa)
		
		# Dropdown de Selección de Mapa (y=340)
		option_mapa = OptionButton.new()
		option_mapa.position = Vector2(225, 336)
		option_mapa.custom_minimum_size = Vector2(220, 35)
		option_mapa.add_item("Atardecer Imperial")
		option_mapa.add_item("Noche Mística")
		option_mapa.selected = Global.mapa_seleccionado
		ventana_ajustes.add_child(option_mapa)

func mostrar_panel(modo: String):
	if ventana_reglas: ventana_reglas.hide()
	if ventana_ajustes:
		ventana_ajustes.show()
		if modo == "audio":
			if titulo_ajustes: 
				titulo_ajustes.texture = tex_titulo_audio
				titulo_ajustes.self_modulate = Color(1, 1, 1, 1)
			if label_volumen: 
				label_volumen.show()
				label_volumen.position = Vector2(40, 200)
			if slider_volumen: 
				slider_volumen.show()
				slider_volumen.position = Vector2(230, 206)
			if check_audio_arriba: check_audio_arriba.show()
			if boton_creditos: boton_creditos.show()
			if label_info_creditos: label_info_creditos.hide()
			
			if modo_juego_label: modo_juego_label.hide()
			if option_modo: option_modo.hide()
			if label_tiempo: label_tiempo.hide()
			if option_tiempo: option_tiempo.hide()
			if label_mapa: label_mapa.hide()
			if option_mapa: option_mapa.hide()
			if boton_comenzar_partida: boton_comenzar_partida.hide()
			
		elif modo == "jugar":
			if titulo_ajustes: 
				titulo_ajustes.texture = tex_titulo_ajustes
				titulo_ajustes.self_modulate = Color(1, 1, 1, 1)
			if label_volumen: label_volumen.hide()
			if slider_volumen: slider_volumen.hide()
			if check_audio_arriba: check_audio_arriba.hide()
			if boton_creditos: boton_creditos.hide()
			if label_info_creditos: label_info_creditos.hide()
			
			if modo_juego_label: 
				modo_juego_label.show()
				modo_juego_label.position = Vector2(40, 200)
			if option_modo: 
				option_modo.show()
				option_modo.position = Vector2(225, 196)
			if label_tiempo: 
				label_tiempo.show()
				label_tiempo.position = Vector2(40, 270)
			if option_tiempo: 
				option_tiempo.show()
				option_tiempo.position = Vector2(225, 266)
			if label_mapa: label_mapa.show()
			if option_mapa: option_mapa.show()
			if boton_comenzar_partida: 
				boton_comenzar_partida.show()
				boton_comenzar_partida.position = Vector2(130, 420)

func _on_boton_jugar_pressed():
	mostrar_panel("jugar")

func _on_boton_opciones_pressed():
	mostrar_panel("audio")

func _on_audio_arriba_toggled(toggled_on: bool):
	var bus_idx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(bus_idx, toggled_on)
	if musica_fondo:
		musica_fondo.stream_paused = toggled_on

func _on_boton_comenzar_partida_pressed():
	if option_modo:
		var seleccion = option_modo.selected
		match seleccion:
			0: Global.num_jugadores = 2
			1: Global.num_jugadores = 3
			2: Global.num_jugadores = 4
			3: Global.num_jugadores = 6
			_: Global.num_jugadores = 2
			
	if option_tiempo:
		Global.tiempo_turno_idx = option_tiempo.selected
		
	# NUEVO: Guardar el escenario seleccionado
	if option_mapa:
		Global.mapa_seleccionado = option_mapa.selected
		
	get_tree().change_scene_to_file("res://scenes/Tablero.tscn")

func _on_boton_como_jugar_pressed():
	if ventana_ajustes: ventana_ajustes.hide()
	if ventana_reglas: ventana_reglas.show()

func _on_boton_cerrar_reglas_pressed():
	if ventana_reglas: ventana_reglas.hide()

func _on_boton_cerrar_ajustes_pressed():
	if ventana_ajustes: ventana_ajustes.hide()

func _on_slider_volumen_value_changed(value: float) -> void:
	var bus_idx = AudioServer.get_bus_index("Master")
	if value <= 0.01:
		AudioServer.set_bus_mute(bus_idx, true)
		if check_audio_arriba: check_audio_arriba.button_pressed = true
	else:
		AudioServer.set_bus_mute(bus_idx, false)
		if check_audio_arriba: check_audio_arriba.button_pressed = false
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))
		
func _on_boton_creditos_pressed():
	if label_info_creditos:
		label_info_creditos.visible = not label_info_creditos.visible
