extends Node2D

var casilla_escena = preload("res://scenes/casilla.tscn")
var ficha_escena = preload("res://scenes/ficha.tscn")
var script_preguntas = preload("res://scripts/preguntas.gd").new()

var matriz_tablero = {} 
var matriz_fichas = {}  

var turno_actual : int = 0 
var num_jugadores_activo : int = 2
var ficha_seleccionada = null
var coord_seleccionada : Vector2 = Vector2(-1, -1)
var ha_saltado_en_turno : bool = false

# Elementos de la Interfaz
var label_turno : Label
var label_monedas : Label
var label_tiempo : Label
var btn_super : Button
var panel_pregunta : PanelContainer
var label_pregunta_texto : Label
var vbox_respuestas : VBoxContainer
var boton_comodin : Button
var cartel_victoria : PanelContainer
var label_victoria : Label
var estilo_vic : StyleBoxFlat

# Reproductores de Audio MP3
var sfx_fichasonido : AudioStreamPlayer 
var sfx_supersalto : AudioStreamPlayer 
var sfx_correcto : AudioStreamPlayer 
var sfx_error : AudioStreamPlayer 
var sfx_victoria : AudioStreamPlayer 

# Variables de Tienda y Tiempo
var modo_super_salto : bool = false
var comodin_activo : bool = false
var recompensa_pendiente : int = 0
var tiempo_restante : float = 0.0
var limite_tiempo : float = 0.0
var tiene_limite_tiempo : bool = false

var colores_jugadores = [
	Color(0.3, 0.95, 0.3), Color(1.0, 0.9, 0.2), Color(0.8, 0.4, 0.95),
	Color(0.95, 0.95, 0.95), Color(1.0, 0.3, 0.3), Color(0.3, 0.7, 1.0)
]
var nombres_jugadores = ["Verde", "Amarillo", "Violeta", "Blanco", "Rojo", "Azul"]
var casas_meta = {0: 3, 1: 4, 2: 5, 3: 0, 4: 1, 5: 2}

var espaciado : float = 28.5
var centro_tablero = Vector2(576.0, 324.0)

func _ready() -> void:
	if Global:
		num_jugadores_activo = Global.num_jugadores
		Global.inicializar_monedas(num_jugadores_activo)
		match Global.tiempo_turno_idx:
			0: limite_tiempo = 16.0; tiene_limite_tiempo = true
			1: limite_tiempo = 31.0; tiene_limite_tiempo = true
			2: limite_tiempo = 61.0; tiene_limite_tiempo = true
			3: tiene_limite_tiempo = false

	# Configuración de reproductores MP3
	inicializar_sonidos()

	# Cargar escenario dinámico en capa trasera (Layer -1)
	var canvas_fondo = CanvasLayer.new()
	canvas_fondo.layer = -1
	add_child(canvas_fondo)

	var fondo_pantalla = Sprite2D.new()
	fondo_pantalla.centered = false
	
	var tex_cargar : Texture2D = null

	# Lista de posibles rutas para asegurar la carga del Mapa 0
	var posibles_mapa_0 = [
		"res://assets/mapa_0.png",
		"res://assets/mapa_0.jpg",
		"res://assets/fondo_tablero.jpg",
		"res://assets/fondo_tablero.png",
		"res://assets/tablero.png"
	]
	
	var posibles_mapa_1 = [
		"res://assets/mapa_1.png",
		"res://assets/mapa_1.jpg"
	]

	if Global.mapa_seleccionado == 1:
		for ruta in posibles_mapa_1:
			if ResourceLoader.exists(ruta):
				tex_cargar = load(ruta)
				break

	if tex_cargar == null:
		for ruta in posibles_mapa_0:
			if ResourceLoader.exists(ruta):
				tex_cargar = load(ruta)
				break

	if tex_cargar:
		fondo_pantalla.texture = tex_cargar
		var tam_pantalla = Vector2(1152.0, 648.0)
		var tam_tex = Vector2(tex_cargar.get_width(), tex_cargar.get_height())
		fondo_pantalla.scale = tam_pantalla / tam_tex

	canvas_fondo.add_child(fondo_pantalla)

	generar_tablero_completo()
	asignar_casillas_especiales()
	colocar_fichas_iniciales()
	crear_interfaz_juego()
	crear_interfaz_pregunta()
	crear_interfaz_victoria()
	queue_redraw()

func inicializar_sonidos():
	sfx_fichasonido = AudioStreamPlayer.new()
	sfx_supersalto = AudioStreamPlayer.new()
	sfx_correcto = AudioStreamPlayer.new()
	sfx_error = AudioStreamPlayer.new()
	sfx_victoria = AudioStreamPlayer.new()
	
	add_child(sfx_fichasonido)
	add_child(sfx_supersalto)
	add_child(sfx_correcto)
	add_child(sfx_error)
	add_child(sfx_victoria)

	if ResourceLoader.exists("res://assets/fichasonido.mp3"):
		sfx_fichasonido.stream = load("res://assets/fichasonido.mp3")
	if ResourceLoader.exists("res://assets/supersalto.mp3"):
		sfx_supersalto.stream = load("res://assets/supersalto.mp3")
	if ResourceLoader.exists("res://assets/correcto.mp3"):
		sfx_correcto.stream = load("res://assets/correcto.mp3")
	if ResourceLoader.exists("res://assets/error.mp3"):
		sfx_error.stream = load("res://assets/error.mp3")
	if ResourceLoader.exists("res://assets/victoria.mp3"):
		sfx_victoria.stream = load("res://assets/victoria.mp3")

func _process(delta: float) -> void:
	if tiene_limite_tiempo and not panel_pregunta.visible and not cartel_victoria.visible:
		tiempo_restante -= delta
		if tiempo_restante <= 0:
			tiempo_restante = 0
			if sfx_error.stream:
				sfx_error.play() # Reproduce sonido de error cuando se agota el tiempo
			terminar_turno()
		
		if tiempo_restante <= 6.0:
			label_tiempo.add_theme_color_override("font_color", Color.RED)
		else:
			label_tiempo.add_theme_color_override("font_color", Color.WHITE)
			
		label_tiempo.text = "Tiempo: " + str(int(tiempo_restante)) + "s"
	elif not tiene_limite_tiempo:
		label_tiempo.text = "Tiempo: ∞"

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_M:
			Global.monedas_jugadores[turno_actual] += 100
			if sfx_correcto.stream: sfx_correcto.play()
			actualizar_indicador_turno()
		if event.keycode == KEY_V:
			lanzar_victoria(turno_actual)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if panel_pregunta.visible or cartel_victoria.visible: return
		
		var mouse_pos = get_global_mouse_position()
		var coord_click = Vector2(-1, -1)
		for coord in matriz_tablero.keys():
			if matriz_tablero[coord].position.distance_to(mouse_pos) < 14.0:
				coord_click = coord
				break
		if coord_click != Vector2(-1, -1):
			_on_casilla_seleccionada(coord_click)

func generar_tablero_completo():
	var distribucion_filas = [1, 2, 3, 4, 13, 12, 11, 10, 9, 10, 11, 12, 13, 4, 3, 2, 1]
	for fila_y in range(distribucion_filas.size()):
		var pos_y = centro_tablero.y + ((fila_y - 8) * (espaciado * 0.866025))
		var ancho_fila = (distribucion_filas[fila_y] - 1) * espaciado
		var inicio_x = centro_tablero.x - (ancho_fila / 2.0)
		for i in range(distribucion_filas[fila_y]):
			var columna_logica = i + int((13 - distribucion_filas[fila_y]) / 2.0)
			crear_casilla_en_pos(Vector2(inicio_x + (i * espaciado), pos_y), Vector2(columna_logica, fila_y))

func crear_casilla_en_pos(posicion_pantalla: Vector2, coord_logica: Vector2):
	var nueva_casilla = casilla_escena.instantiate()
	nueva_casilla.position = posicion_pantalla
	add_child(nueva_casilla)
	nueva_casilla.coordenadas = coord_logica
	matriz_tablero[coord_logica] = nueva_casilla

func obtener_casa_id(coord: Vector2) -> int:
	var r = int(coord.y); var c = int(coord.x)
	if r <= 3: return 0
	if r >= 13: return 3
	if r >= 4 and r <= 7 and c < 4: return 5
	if r >= 4 and r <= 7 and c > 8: return 1
	if r >= 9 and r <= 12 and c < 4: return 4
	if r >= 9 and r <= 12 and c > 8: return 2
	return -1

func colocar_fichas_iniciales():
	var casas_activas = []
	match num_jugadores_activo:
		2: casas_activas = [0, 3]
		3: casas_activas = [0, 2, 4]
		4: casas_activas = [1, 2, 4, 5]
		6: casas_activas = [0, 1, 2, 3, 4, 5]
		_: casas_activas = [0, 3]

	for coord in matriz_tablero.keys():
		var casa = obtener_casa_id(coord)
		if casa != -1 and casa in casas_activas:
			var jugador_id = casas_activas.find(casa)
			crear_ficha(coord, jugador_id)

func crear_ficha(coord: Vector2, jugador_id: int):
	var casilla = matriz_tablero[coord]
	var nueva_ficha = ficha_escena.instantiate()
	add_child(nueva_ficha)
	nueva_ficha.position = casilla.position
	nueva_ficha.set_jugador(jugador_id)
	matriz_fichas[coord] = nueva_ficha

func asignar_casillas_especiales():
	var coords = matriz_tablero.keys()
	coords.shuffle()
	var especiales_asignadas = 0
	for coord in coords:
		if obtener_casa_id(coord) == -1: 
			var rand = randi() % 100
			if rand < 15: matriz_tablero[coord].tipo_casilla = "unidad_iii"
			elif rand < 25: matriz_tablero[coord].tipo_casilla = "cultura_general"
			elif rand < 30: matriz_tablero[coord].tipo_casilla = "cofre_sorpresa"
			matriz_tablero[coord].queue_redraw()
			especiales_asignadas += 1
			if especiales_asignadas > 20: break

func crear_interfaz_juego():
	var canvas = CanvasLayer.new()
	add_child(canvas)
	
	var cont_marco = Control.new()
	cont_marco.position = Vector2(15, 10)
	canvas.add_child(cont_marco)
	var fondo_placa = TextureRect.new()
	fondo_placa.texture = load("res://assets/marco_titulo.png")
	fondo_placa.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fondo_placa.custom_minimum_size = Vector2(320, 72)
	fondo_placa.size = Vector2(320, 72)
	cont_marco.add_child(fondo_placa)
	
	label_turno = Label.new()
	label_turno.position = Vector2(0, 20)
	label_turno.custom_minimum_size = Vector2(320, 32)
	label_turno.add_theme_font_size_override("font_size", 24)
	label_turno.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label_turno.add_theme_constant_override("outline_size", 5)
	label_turno.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cont_marco.add_child(label_turno)

	var cont_tiempo = PanelContainer.new()
	cont_tiempo.position = Vector2(500, 25)
	var estilo_tiempo = StyleBoxFlat.new()
	estilo_tiempo.bg_color = Color(0.06, 0.22, 0.18, 0.8)
	estilo_tiempo.border_color = Color.GOLD
	estilo_tiempo.set_border_width_all(2)
	estilo_tiempo.set_corner_radius_all(10)
	estilo_tiempo.content_margin_left = 15; estilo_tiempo.content_margin_right = 15
	cont_tiempo.add_theme_stylebox_override("panel", estilo_tiempo)
	
	label_tiempo = Label.new()
	label_tiempo.add_theme_font_size_override("font_size", 22)
	label_tiempo.add_theme_color_override("font_outline_color", Color.BLACK)
	label_tiempo.add_theme_constant_override("outline_size", 4)
	cont_tiempo.add_child(label_tiempo)
	canvas.add_child(cont_tiempo)

	var boton_volver = TextureButton.new()
	boton_volver.texture_normal = load("res://assets/images-removebg-preview.png")
	boton_volver.ignore_texture_size = true
	boton_volver.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	boton_volver.custom_minimum_size = Vector2(58, 58)
	boton_volver.position = Vector2(1072, 548)
	boton_volver.pressed.connect(func(): 
		get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")
	)
	canvas.add_child(boton_volver)

	var panel_tienda = PanelContainer.new()
	panel_tienda.position = Vector2(15, 90)
	var estilo_tienda = StyleBoxFlat.new()
	estilo_tienda.bg_color = Color(0, 0, 0, 0.6)
	estilo_tienda.set_corner_radius_all(10)
	estilo_tienda.content_margin_left = 15; estilo_tienda.content_margin_right = 15
	estilo_tienda.content_margin_top = 15; estilo_tienda.content_margin_bottom = 15
	panel_tienda.add_theme_stylebox_override("panel", estilo_tienda)
	canvas.add_child(panel_tienda)

	var vbox_tienda = VBoxContainer.new()
	vbox_tienda.add_theme_constant_override("separation", 10)
	panel_tienda.add_child(vbox_tienda)

	label_monedas = Label.new()
	label_monedas.add_theme_font_size_override("font_size", 26)
	label_monedas.add_theme_color_override("font_outline_color", Color.BLACK)
	label_monedas.add_theme_constant_override("outline_size", 6)
	vbox_tienda.add_child(label_monedas)
	
	btn_super = Button.new()
	btn_super.text = "Súper Salto (30 M)"
	btn_super.add_theme_font_size_override("font_size", 16)
	btn_super.custom_minimum_size = Vector2(180, 40)
	btn_super.pressed.connect(activar_super_salto)
	vbox_tienda.add_child(btn_super)
	
	actualizar_indicador_turno()

func actualizar_indicador_turno():
	label_turno.text = "Turno: " + nombres_jugadores[turno_actual]
	label_turno.add_theme_color_override("font_color", colores_jugadores[turno_actual])
	label_monedas.text = "Monedas: " + str(Global.monedas_jugadores[turno_actual])
	label_monedas.add_theme_color_override("font_color", colores_jugadores[turno_actual])
	modo_super_salto = false
	comodin_activo = false
	btn_super.text = "Súper Salto (30 M)"
	
	tiempo_restante = limite_tiempo
	label_tiempo.add_theme_color_override("font_color", Color.WHITE)

func _draw() -> void:
	for coord in matriz_tablero.keys():
		var pos = matriz_tablero[coord].position
		draw_circle(pos + Vector2(0, 1), 11.0, Color(0, 0, 0, 0.4))
		draw_circle(pos, 10.0, Color(0.22, 0.11, 0.04))
		draw_arc(pos, 10.0, 0, TAU, 32, Color(0.12, 0.05, 0.02), 1.5, true)
	
	var coords = matriz_tablero.keys()
	for i in range(coords.size()):
		for j in range(i + 1, coords.size()):
			var c1 = coords[i]; var c2 = coords[j]
			var p1 = matriz_tablero[c1].position; var p2 = matriz_tablero[c2].position
			if p1.distance_to(p2) > (espaciado * 0.8) and p1.distance_to(p2) < (espaciado * 1.2):
				draw_line(p1, p2, Color(0.2, 0.1, 0.03, 0.5), 1.5, true)

func _on_casilla_seleccionada(coord: Vector2):
	if coord == coord_seleccionada and ha_saltado_en_turno:
		terminar_turno()
		return
		
	if matriz_fichas.has(coord):
		var ficha = matriz_fichas[coord]
		if ficha.jugador_id == turno_actual:
			if not ha_saltado_en_turno:
				deseleccionar_ficha_actual()
				ficha_seleccionada = ficha
				coord_seleccionada = coord
				ficha.set_seleccionada(true)
	elif ficha_seleccionada != null:
		var tipo_mov = evaluar_movimiento(coord_seleccionada, coord)
		
		if modo_super_salto and tipo_mov == "super_salto":
			mover_ficha(coord_seleccionada, coord)
			terminar_turno()
		elif tipo_mov == "paso" and not ha_saltado_en_turno:
			mover_ficha(coord_seleccionada, coord)
			terminar_turno()
		elif tipo_mov == "salto":
			mover_ficha(coord_seleccionada, coord)
			ha_saltado_en_turno = true
			coord_seleccionada = coord
			ficha_seleccionada.set_seleccionada(true)

func evaluar_movimiento(origen: Vector2, destino: Vector2) -> String:
	if matriz_fichas.has(destino): return "invalido"
	var pos_origen = matriz_tablero[origen].position
	var pos_destino = matriz_tablero[destino].position
	var dist = pos_origen.distance_to(pos_destino)
	
	if modo_super_salto:
		if dist > 35.0 and dist <= 120.0:
			return "super_salto"

	if dist > 20.0 and dist < 35.0:
		return "paso"
	if dist > 50.0 and dist < 65.0:
		var punto_medio = (pos_origen + pos_destino) / 2.0
		for ficha in matriz_fichas.values():
			if ficha.position.distance_to(punto_medio) < 15.0:
				return "salto"
	return "invalido"

func mover_ficha(origen: Vector2, destino: Vector2):
	ficha_seleccionada.position = matriz_tablero[destino].position
	matriz_fichas[destino] = ficha_seleccionada
	matriz_fichas.erase(origen)
	
	if modo_super_salto:
		if sfx_supersalto.stream: sfx_supersalto.play()
	else:
		if sfx_fichasonido.stream: sfx_fichasonido.play()
	
	verificar_victoria()
	
	var casilla = matriz_tablero[destino]
	if casilla.tipo_casilla != "normal":
		activar_pregunta(casilla.tipo_casilla)
		casilla.tipo_casilla = "normal"
		casilla.queue_redraw()

func terminar_turno():
	deseleccionar_ficha_actual()
	ha_saltado_en_turno = false
	turno_actual = (turno_actual + 1) % num_jugadores_activo
	actualizar_indicador_turno()

func deseleccionar_ficha_actual():
	if ficha_seleccionada:
		ficha_seleccionada.set_seleccionada(false)
		ficha_seleccionada = null
		coord_seleccionada = Vector2(-1, -1)

# --- SISTEMA DE PREGUNTAS ---
func crear_interfaz_pregunta():
	panel_pregunta = PanelContainer.new()
	panel_pregunta.position = Vector2(350, 150)
	panel_pregunta.custom_minimum_size = Vector2(450, 350)
	panel_pregunta.hide()
	
	var estilo = StyleBoxFlat.new()
	estilo.bg_color = Color(0.1, 0.2, 0.15, 0.95)
	estilo.border_color = Color.GOLD
	estilo.set_border_width_all(4)
	estilo.set_corner_radius_all(15)
	panel_pregunta.add_theme_stylebox_override("panel", estilo)
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 15)
	
	label_pregunta_texto = Label.new()
	label_pregunta_texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_pregunta_texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label_pregunta_texto.add_theme_font_size_override("font_size", 22)
	vbox.add_child(label_pregunta_texto)
	
	vbox_respuestas = VBoxContainer.new()
	vbox_respuestas.add_theme_constant_override("separation", 10)
	vbox.add_child(vbox_respuestas)
	
	boton_comodin = Button.new()
	boton_comodin.text = "Usar Comodín 50/50 (20 Monedas)"
	boton_comodin.add_theme_font_size_override("font_size", 18)
	boton_comodin.add_theme_color_override("font_color", Color.GOLD)
	boton_comodin.pressed.connect(usar_comodin)
	vbox.add_child(boton_comodin)
	
	panel_pregunta.add_child(vbox)
	add_child(panel_pregunta)

var respuesta_correcta_idx = 0
func activar_pregunta(tipo: String):
	var preg = script_preguntas.obtener_pregunta_aleatoria(tipo)
	if preg.is_empty(): return
	
	match tipo:
		"unidad_iii": recompensa_pendiente = 50
		"cultura_general": recompensa_pendiente = 25
		"cofre_sorpresa": recompensa_pendiente = 100
		
	label_pregunta_texto.text = "RECOMPENSA: +" + str(recompensa_pendiente) + "M\n\n" + preg["pregunta"]
	respuesta_correcta_idx = preg["correcta"]
	
	for n in vbox_respuestas.get_children(): n.queue_free()
	
	for i in range(preg["opciones"].size()):
		var btn = Button.new()
		btn.text = preg["opciones"][i]
		btn.add_theme_font_size_override("font_size", 20)
		btn.custom_minimum_size = Vector2(300, 40)
		btn.pressed.connect(func(): verificar_respuesta(i))
		vbox_respuestas.add_child(btn)
		
	boton_comodin.disabled = false
	panel_pregunta.show()

func verificar_respuesta(idx: int):
	panel_pregunta.hide()
	if idx == respuesta_correcta_idx:
		Global.monedas_jugadores[turno_actual] += recompensa_pendiente
		if sfx_correcto.stream: sfx_correcto.play()
		actualizar_indicador_turno()
	else:
		if sfx_error.stream: sfx_error.play()

func activar_super_salto():
	if Global.monedas_jugadores[turno_actual] >= 30 and not modo_super_salto:
		Global.monedas_jugadores[turno_actual] -= 30
		modo_super_salto = true
		btn_super.text = "¡SÚPER SALTO ACTIVO!"
		actualizar_indicador_turno() 
		modo_super_salto = true

func usar_comodin():
	if Global.monedas_jugadores[turno_actual] >= 20 and not comodin_activo:
		Global.monedas_jugadores[turno_actual] -= 20
		comodin_activo = true
		if sfx_correcto.stream: sfx_correcto.play()
		actualizar_indicador_turno()
		boton_comodin.disabled = true
		var botones = vbox_respuestas.get_children()
		var eliminados = 0
		for i in range(botones.size()):
			if i != respuesta_correcta_idx and eliminados < 2:
				botones[i].disabled = true
				eliminados += 1

func crear_interfaz_victoria():
	cartel_victoria = PanelContainer.new()
	cartel_victoria.position = Vector2(300, 200)
	cartel_victoria.custom_minimum_size = Vector2(550, 200)
	cartel_victoria.hide()
	
	estilo_vic = StyleBoxFlat.new()
	estilo_vic.border_color = Color.WHITE
	estilo_vic.set_border_width_all(5)
	estilo_vic.set_corner_radius_all(20)
	cartel_victoria.add_theme_stylebox_override("panel", estilo_vic)
	
	var vbox_vic = VBoxContainer.new()
	vbox_vic.alignment = BoxContainer.ALIGNMENT_CENTER
	
	label_victoria = Label.new()
	label_victoria.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_victoria.add_theme_font_size_override("font_size", 45)
	label_victoria.add_theme_color_override("font_outline_color", Color(0,0,0,1))
	label_victoria.add_theme_constant_override("outline_size", 8)
	vbox_vic.add_child(label_victoria)
	
	var btn_volver = Button.new()
	btn_volver.text = "VOLVER AL MENÚ"
	btn_volver.add_theme_font_size_override("font_size", 25)
	btn_volver.pressed.connect(func(): 
		get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")
	)
	vbox_vic.add_child(btn_volver)
	
	cartel_victoria.add_child(vbox_vic)
	add_child(cartel_victoria)

func lanzar_victoria(id_ganador: int):
	label_victoria.text = "¡JUGADOR " + nombres_jugadores[id_ganador].to_upper() + " GANA!"
	estilo_vic.bg_color = colores_jugadores[id_ganador]
	estilo_vic.bg_color = estilo_vic.bg_color.darkened(0.2)
	if sfx_victoria.stream: sfx_victoria.play()
	cartel_victoria.show()

func verificar_victoria():
	var id_jugador = ficha_seleccionada.jugador_id
	var meta = casas_meta[id_jugador]
	var fichas_en_meta = 0
	
	for coord in matriz_fichas.keys():
		if matriz_fichas[coord].jugador_id == id_jugador:
			if obtener_casa_id(coord) == meta:
				fichas_en_meta += 1
				
	if fichas_en_meta == 10: 
		lanzar_victoria(id_jugador)
