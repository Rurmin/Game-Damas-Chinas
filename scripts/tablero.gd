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
var label_progreso_meta : Label
var label_tiempo : Label
var btn_super : Button
var btn_doble_jugada : Button
var btn_congelar : Button
var btn_terminar_turno : Button
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
var sfx_congelar : AudioStreamPlayer 
var sfx_compra : AudioStreamPlayer 

# Variables de Tienda y Tiempo
var modo_super_salto : bool = false
var doble_jugada_activa : bool = false
var modo_congelar : bool = false
var comodin_activo : bool = false
var recompensa_pendiente : int = 0
var tipo_pregunta_actual : String = ""
var jugador_pregunta : int = 0
var turno_pendiente_terminar : bool = false
var respondiendo_pregunta : bool = false
var tiempo_restante : float = 0.0
var limite_tiempo : float = 0.0
var tiene_limite_tiempo : bool = false

var casillas_validas : Array[Vector2] = []
var casas_origen_jugador = {}
var cargas_super_salto = {}
var cargas_doble_jugada = {}
var super_usado_gratis : bool = false
var doble_usado_gratis : bool = false
var contador_turnos_cajas : int = 0

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
	sfx_congelar = AudioStreamPlayer.new()
	sfx_compra = AudioStreamPlayer.new()
	
	for reproductor in [sfx_fichasonido, sfx_supersalto, sfx_correcto, sfx_error, sfx_victoria, sfx_congelar, sfx_compra]:
		reproductor.volume_db = -2.5
		add_child(reproductor)

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
	if ResourceLoader.exists("res://assets/congelar.mp3"):
		sfx_congelar.stream = load("res://assets/congelar.mp3")
	if ResourceLoader.exists("res://assets/compra.mp3"):
		sfx_compra.stream = load("res://assets/compra.mp3")

func reproducir_sonido_congelar():
	if sfx_congelar and sfx_congelar.stream:
		sfx_congelar.play(0.0)
		get_tree().create_timer(2.0).timeout.connect(func():
			if is_instance_valid(sfx_congelar) and sfx_congelar.playing:
				sfx_congelar.stop()
		)
	elif sfx_supersalto and sfx_supersalto.stream:
		sfx_supersalto.play()

func _process(delta: float) -> void:
	if tiene_limite_tiempo and not panel_pregunta.visible and not cartel_victoria.visible:
		tiempo_restante -= delta
		if tiempo_restante <= 0:
			tiempo_restante = 0
			if sfx_error.stream:
				sfx_error.play() # Reproduce sonido de error cuando se agota el tiempo
			terminar_turno(true)
		
		if tiempo_restante <= 6.0:
			label_tiempo.add_theme_color_override("font_color", Color.RED)
		else:
			label_tiempo.add_theme_color_override("font_color", Color.WHITE)
			
		label_tiempo.text = "Tiempo: " + str(int(tiempo_restante)) + "s"
	elif not tiene_limite_tiempo:
		label_tiempo.text = "Tiempo: ∞"

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
			crear_casilla_en_pos(Vector2(inicio_x + (i * espaciado), pos_y), Vector2(i, fila_y))

func crear_casilla_en_pos(posicion_pantalla: Vector2, coord_logica: Vector2):
	var nueva_casilla = casilla_escena.instantiate()
	nueva_casilla.position = posicion_pantalla
	add_child(nueva_casilla)
	nueva_casilla.coordenadas = coord_logica
	matriz_tablero[coord_logica] = nueva_casilla

func obtener_casa_id(coord: Vector2) -> int:
	var r = int(coord.y)
	var i = int(coord.x)
	if r <= 3: return 0
	if r >= 13: return 3
	if r >= 4 and r <= 7:
		if i < (8 - r): return 5
		if i >= 9: return 1
	if r >= 9 and r <= 12:
		if i < (r - 8): return 4
		if i >= 9: return 2
	return -1

func colocar_fichas_iniciales():
	var casas_activas = []
	match num_jugadores_activo:
		2: casas_activas = [0, 3]
		3: casas_activas = [0, 2, 4]
		4: casas_activas = [1, 2, 4, 5]
		6: casas_activas = [0, 1, 2, 3, 4, 5]
		_: casas_activas = [0, 3]

	casas_origen_jugador.clear()
	for i in range(casas_activas.size()):
		casas_origen_jugador[i] = casas_activas[i]

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

func obtener_sector_tablero(coord: Vector2) -> int:
	var pos = matriz_tablero[coord].position
	var delta = pos - centro_tablero
	if delta.length() < 5.0:
		return -1
	var angulo = fposmod(atan2(delta.y, delta.x) + PI / 6.0, TAU)
	return clampi(int(floor(angulo / (TAU / 6.0))), 0, 5)

func asignar_casillas_especiales():
	var sectores = {0: [], 1: [], 2: [], 3: [], 4: [], 5: []}
	for coord in matriz_tablero.keys():
		if obtener_casa_id(coord) == -1 and coord != Vector2(0, 0):
			var sec = obtener_sector_tablero(coord)
			if sec >= 0 and sec <= 5:
				sectores[sec].append(coord)

	# Bolsa balanceada con exactamente 4 de cada tipo (12 cajas iniciales en total, 2 por cada lado/sector)
	var bolsa_tipos = [
		"unidad_iii", "cultura_general", "cofre_sorpresa",
		"unidad_iii", "cultura_general", "cofre_sorpresa",
		"unidad_iii", "cultura_general", "cofre_sorpresa",
		"unidad_iii", "cultura_general", "cofre_sorpresa"
	]
	bolsa_tipos.shuffle()

	# Asegurar que en un mismo sector no se repita el mismo tipo si es posible
	for sec in range(6):
		var idx1 = sec * 2
		var idx2 = sec * 2 + 1
		if bolsa_tipos[idx1] == bolsa_tipos[idx2]:
			for otro in range(bolsa_tipos.size()):
				if otro != idx1 and otro != idx2 and bolsa_tipos[otro] != bolsa_tipos[idx1]:
					var otro_par = otro + 1 if otro % 2 == 0 else otro - 1
					if bolsa_tipos[otro_par] != bolsa_tipos[idx2]:
						var temp = bolsa_tipos[idx2]
						bolsa_tipos[idx2] = bolsa_tipos[otro]
						bolsa_tipos[otro] = temp
						break

	var seleccionadas : Array[Vector2] = []
	var idx_bolsa = 0
	for sec in range(6):
		var candidatas : Array = sectores[sec]
		candidatas.shuffle()
		var puestas_en_sector = 0
		for coord in candidatas:
			var muy_cerca = false
			for prev in seleccionadas:
				if matriz_tablero[coord].position.distance_to(matriz_tablero[prev].position) < espaciado * 1.35:
					muy_cerca = true
					break
			if not muy_cerca:
				matriz_tablero[coord].tipo_casilla = bolsa_tipos[idx_bolsa]
				matriz_tablero[coord].queue_redraw()
				seleccionadas.append(coord)
				idx_bolsa += 1
				puestas_en_sector += 1
				if puestas_en_sector >= 2:
					break
		# Respaldo si por distancia no se completaron las 2 del sector
		if puestas_en_sector < 2:
			for coord in candidatas:
				if not seleccionadas.has(coord):
					matriz_tablero[coord].tipo_casilla = bolsa_tipos[idx_bolsa]
					matriz_tablero[coord].queue_redraw()
					seleccionadas.append(coord)
					idx_bolsa += 1
					puestas_en_sector += 1
					if puestas_en_sector >= 2:
						break

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
	boton_volver.texture_normal = load("res://assets/boton_salir.png")
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

	label_progreso_meta = Label.new()
	label_progreso_meta.add_theme_font_size_override("font_size", 18)
	label_progreso_meta.add_theme_color_override("font_outline_color", Color.BLACK)
	label_progreso_meta.add_theme_constant_override("outline_size", 5)
	vbox_tienda.add_child(label_progreso_meta)
	
	btn_super = Button.new()
	btn_super.text = "Súper Salto (30 M)"
	btn_super.add_theme_font_size_override("font_size", 16)
	btn_super.custom_minimum_size = Vector2(180, 40)
	btn_super.pressed.connect(activar_super_salto)
	vbox_tienda.add_child(btn_super)

	btn_doble_jugada = Button.new()
	btn_doble_jugada.text = "Doble Jugada (45 M)"
	btn_doble_jugada.add_theme_font_size_override("font_size", 16)
	btn_doble_jugada.custom_minimum_size = Vector2(180, 40)
	btn_doble_jugada.pressed.connect(activar_doble_jugada)
	vbox_tienda.add_child(btn_doble_jugada)

	btn_congelar = Button.new()
	btn_congelar.text = "Congelar Rival (35 M)"
	btn_congelar.add_theme_font_size_override("font_size", 16)
	btn_congelar.custom_minimum_size = Vector2(180, 40)
	btn_congelar.pressed.connect(activar_congelar)
	vbox_tienda.add_child(btn_congelar)

	btn_terminar_turno = Button.new()
	btn_terminar_turno.text = "Pasar Turno"
	btn_terminar_turno.add_theme_font_size_override("font_size", 16)
	btn_terminar_turno.custom_minimum_size = Vector2(180, 40)
	btn_terminar_turno.pressed.connect(func():
		if not panel_pregunta.visible and not cartel_victoria.visible and not respondiendo_pregunta:
			terminar_turno()
	)
	vbox_tienda.add_child(btn_terminar_turno)
	
	actualizar_indicador_turno()

func contar_fichas_en_meta(id_jugador: int) -> int:
	var casa_origen = casas_origen_jugador.get(id_jugador, id_jugador)
	var meta = casas_meta[casa_origen]
	var cuenta = 0
	for coord in matriz_fichas.keys():
		if matriz_fichas[coord].jugador_id == id_jugador and obtener_casa_id(coord) == meta:
			cuenta += 1
	return cuenta

func actualizar_texto_progreso():
	if label_progreso_meta:
		var en_meta = contar_fichas_en_meta(turno_actual)
		label_progreso_meta.text = "En Meta: " + str(en_meta) + " / 10"
		label_progreso_meta.add_theme_color_override("font_color", colores_jugadores[turno_actual])

func actualizar_texto_botones_habilidades():
	if btn_super:
		if modo_super_salto:
			btn_super.text = "Súper Salto: ACTIVO ✖"
		elif cargas_super_salto.get(turno_actual, 0) > 0:
			btn_super.text = "Usar Súper Salto (GRATIS x" + str(cargas_super_salto[turno_actual]) + ")"
		else:
			btn_super.text = "Súper Salto (30 M)"
			
	if btn_doble_jugada:
		if doble_jugada_activa:
			btn_doble_jugada.text = "Doble Jugada: ACTIVA ✖"
		elif cargas_doble_jugada.get(turno_actual, 0) > 0:
			btn_doble_jugada.text = "Usar Doble Jugada (GRATIS x" + str(cargas_doble_jugada[turno_actual]) + ")"
		else:
			btn_doble_jugada.text = "Doble Jugada (45 M)"
			
	if btn_congelar:
		if modo_congelar:
			btn_congelar.text = "Congelar: ACTIVO ✖"
		else:
			btn_congelar.text = "Congelar Rival (35 M)"

func actualizar_indicador_turno():
	label_turno.text = "Turno: " + nombres_jugadores[turno_actual]
	label_turno.add_theme_color_override("font_color", colores_jugadores[turno_actual])
	label_monedas.text = "Monedas: " + str(Global.monedas_jugadores[turno_actual])
	label_monedas.add_theme_color_override("font_color", colores_jugadores[turno_actual])
	actualizar_texto_progreso()
	
	comodin_activo = false
	modo_super_salto = false
	modo_congelar = false
	super_usado_gratis = false
	doble_usado_gratis = false
	actualizar_texto_botones_habilidades()
		
	if btn_terminar_turno:
		btn_terminar_turno.text = "Pasar Turno"
		btn_terminar_turno.modulate = Color.WHITE
	
	tiempo_restante = limite_tiempo
	label_tiempo.add_theme_color_override("font_color", Color.WHITE)
	queue_redraw()

func actualizar_movimientos_validos():
	casillas_validas.clear()
	if ficha_seleccionada == null or coord_seleccionada == Vector2(-1, -1):
		queue_redraw()
		return
		
	for coord in matriz_tablero.keys():
		var tipo = evaluar_movimiento(coord_seleccionada, coord)
		if modo_super_salto and tipo == "super_salto" and not ha_saltado_en_turno:
			casillas_validas.append(coord)
		elif tipo == "paso" and not ha_saltado_en_turno:
			casillas_validas.append(coord)
		elif tipo == "salto":
			casillas_validas.append(coord)
	queue_redraw()

func _draw() -> void:
	var coords = matriz_tablero.keys()
	for i in range(coords.size()):
		for j in range(i + 1, coords.size()):
			var c1 = coords[i]; var c2 = coords[j]
			var p1 = matriz_tablero[c1].position; var p2 = matriz_tablero[c2].position
			if p1.distance_to(p2) > (espaciado * 0.8) and p1.distance_to(p2) < (espaciado * 1.2):
				draw_line(p1, p2, Color(0.2, 0.1, 0.03, 0.5), 1.5, true)

	for coord in coords:
		var pos = matriz_tablero[coord].position
		draw_circle(pos + Vector2(0, 1), 11.0, Color(0, 0, 0, 0.4))
		draw_circle(pos, 10.0, Color(0.22, 0.11, 0.04))
		
		var casa_id = obtener_casa_id(coord)
		var color_borde = Color(0.12, 0.05, 0.02)
		var grosor_borde = 1.5
		if casa_id != -1:
			for jug_id in casas_origen_jugador.keys():
				var meta_jug = casas_meta[casas_origen_jugador[jug_id]]
				if casa_id == meta_jug:
					var col_jug = colores_jugadores[jug_id]
					if jug_id == turno_actual:
						color_borde = Color(col_jug.r, col_jug.g, col_jug.b, 0.9)
						grosor_borde = 2.6
					else:
						color_borde = Color(col_jug.r, col_jug.g, col_jug.b, 0.45)
						grosor_borde = 2.0
					break
		draw_arc(pos, 10.0, 0, TAU, 32, color_borde, grosor_borde, true)

	for coord in casillas_validas:
		var pos = matriz_tablero[coord].position
		var tipo = evaluar_movimiento(coord_seleccionada, coord)
		var col_guia = Color(0.3, 1.0, 0.55, 0.85)
		if modo_super_salto and tipo == "super_salto":
			col_guia = Color(1.0, 0.85, 0.2, 0.9)
		draw_circle(pos, 5.5, Color(col_guia.r, col_guia.g, col_guia.b, 0.45))
		draw_arc(pos, 11.5, 0, TAU, 32, col_guia, 2.2, true)
		
	if modo_congelar:
		for coord in matriz_fichas.keys():
			var f = matriz_fichas[coord]
			if f.jugador_id != turno_actual and not f.congelada:
				var pos = matriz_tablero[coord].position
				draw_arc(pos, 14.5, 0, TAU, 32, Color(0.3, 0.95, 1.0, 0.95), 2.8, true)

func _on_casilla_seleccionada(coord: Vector2):
	if coord == coord_seleccionada and ha_saltado_en_turno:
		terminar_turno()
		return
		
	if matriz_fichas.has(coord):
		var ficha = matriz_fichas[coord]
		if modo_congelar and ficha.jugador_id != turno_actual and not ficha.congelada:
			ficha.set_congelada(true)
			modo_congelar = false
			reproducir_sonido_congelar()
			var tw = create_tween()
			tw.tween_property(ficha, "scale", Vector2(1.4, 1.4), 0.1).set_trans(Tween.TRANS_SINE)
			tw.tween_property(ficha, "scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_SINE)
			actualizar_texto_botones_habilidades()
			queue_redraw()
			return
		if ficha.jugador_id == turno_actual:
			if ficha.congelada:
				if sfx_error.stream: sfx_error.play()
				return
			if not ha_saltado_en_turno:
				deseleccionar_ficha_actual()
				ficha_seleccionada = ficha
				coord_seleccionada = coord
				ficha.set_seleccionada(true)
				actualizar_movimientos_validos()
	elif ficha_seleccionada != null:
		var tipo_mov = evaluar_movimiento(coord_seleccionada, coord)
		
		if modo_super_salto and tipo_mov == "super_salto" and not ha_saltado_en_turno:
			mover_ficha(coord_seleccionada, coord)
			if panel_pregunta.visible:
				deseleccionar_ficha_actual()
				turno_pendiente_terminar = true
			else:
				terminar_turno()
		elif tipo_mov == "paso" and not ha_saltado_en_turno:
			if modo_super_salto:
				cargas_super_salto[turno_actual] = cargas_super_salto.get(turno_actual, 0) + 1
				modo_super_salto = false
			mover_ficha(coord_seleccionada, coord)
			if panel_pregunta.visible:
				deseleccionar_ficha_actual()
				turno_pendiente_terminar = true
			else:
				terminar_turno()
		elif tipo_mov == "salto":
			mover_ficha(coord_seleccionada, coord)
			ha_saltado_en_turno = true
			coord_seleccionada = coord
			ficha_seleccionada.set_seleccionada(true)
			if btn_terminar_turno:
				btn_terminar_turno.text = "Finalizar Salto ✔"
				btn_terminar_turno.modulate = Color(0.55, 1.0, 0.55)
			actualizar_movimientos_validos()

func evaluar_movimiento(origen: Vector2, destino: Vector2) -> String:
	if matriz_fichas.has(destino): return "invalido"
	var pos_origen = matriz_tablero[origen].position
	var pos_destino = matriz_tablero[destino].position
	var dist = pos_origen.distance_to(pos_destino)
	
	if modo_super_salto and not ha_saltado_en_turno:
		if dist > 35.0 and dist <= 120.0:
			return "super_salto"

	if dist > 20.0 and dist < 35.0:
		return "paso"
	if dist > 50.0 and dist < 65.0:
		var punto_medio = (pos_origen + pos_destino) / 2.0
		for coord_ficha in matriz_fichas.keys():
			if matriz_tablero[coord_ficha].position.distance_to(punto_medio) < 15.0:
				return "salto"
	return "invalido"

func mover_ficha(origen: Vector2, destino: Vector2):
	var ficha_movida = ficha_seleccionada
	var pos_destino = matriz_tablero[destino].position
	matriz_fichas[destino] = ficha_movida
	matriz_fichas.erase(origen)
	
	ficha_movida.z_index = 10
	var tween_pos = create_tween()
	tween_pos.tween_property(ficha_movida, "position", pos_destino, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween_pos.tween_callback(func():
		if is_instance_valid(ficha_movida):
			ficha_movida.z_index = 0
	)
	
	var escala_salto = Vector2(1.55, 1.55) if modo_super_salto else Vector2(1.3, 1.3)
	var tween_escala = create_tween()
	tween_escala.tween_property(ficha_movida, "scale", escala_salto, 0.09).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween_escala.tween_property(ficha_movida, "scale", Vector2.ONE, 0.09).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	if modo_super_salto:
		if sfx_supersalto.stream: sfx_supersalto.play()
	else:
		if sfx_fichasonido.stream: sfx_fichasonido.play()
	
	actualizar_texto_progreso()
	verificar_victoria()
	
	var casilla = matriz_tablero[destino]
	if casilla.tipo_casilla != "normal":
		activar_pregunta(casilla.tipo_casilla)
		casilla.tipo_casilla = "normal"
		casilla.queue_redraw()

func generar_cajas_dinamicas(cantidad: int):
	var actuales = 0
	var conteo_tipos = {"unidad_iii": 0, "cultura_general": 0, "cofre_sorpresa": 0}
	var conteo_sectores = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0}
	var disponibles_por_sector = {0: [], 1: [], 2: [], 3: [], 4: [], 5: []}
	var coords_especiales : Array[Vector2] = []

	for coord in matriz_tablero.keys():
		var cas = matriz_tablero[coord]
		var sec = obtener_sector_tablero(coord)
		if cas.tipo_casilla != "normal":
			actuales += 1
			coords_especiales.append(coord)
			if conteo_tipos.has(cas.tipo_casilla):
				conteo_tipos[cas.tipo_casilla] += 1
			if sec >= 0 and sec <= 5:
				conteo_sectores[sec] += 1
		elif obtener_casa_id(coord) == -1 and coord != Vector2(0, 0) and not matriz_fichas.has(coord):
			if sec >= 0 and sec <= 5:
				disponibles_por_sector[sec].append(coord)

	if actuales >= 18:
		return

	var a_crear = min(cantidad, 18 - actuales)
	for i in range(a_crear):
		# 1. Buscar el sector con menos cajas que tenga casillas libres
		var mejor_sec = -1
		var min_en_sec = 999
		var orden_sec = [0, 1, 2, 3, 4, 5]
		orden_sec.shuffle()
		for sec in orden_sec:
			if not disponibles_por_sector[sec].is_empty() and conteo_sectores[sec] < min_en_sec:
				min_en_sec = conteo_sectores[sec]
				mejor_sec = sec
		if mejor_sec == -1:
			break

		var candidatas : Array = disponibles_por_sector[mejor_sec]
		candidatas.shuffle()
		var coord_elegida = candidatas[0]
		for cand in candidatas:
			var lejos = true
			for esp in coords_especiales:
				if matriz_tablero[cand].position.distance_to(matriz_tablero[esp].position) < espaciado * 1.35:
					lejos = false
					break
			if lejos:
				coord_elegida = cand
				break

		disponibles_por_sector[mejor_sec].erase(coord_elegida)
		conteo_sectores[mejor_sec] += 1
		coords_especiales.append(coord_elegida)

		# 2. Elegir el tipo de objeto con menor cantidad en el tablero para que siempre haya de los 3 tipos
		var tipos_orden = ["unidad_iii", "cultura_general", "cofre_sorpresa"]
		tipos_orden.shuffle()
		var tipo_elegido = tipos_orden[0]
		var min_tipo = 999
		for t in tipos_orden:
			if conteo_tipos[t] < min_tipo:
				min_tipo = conteo_tipos[t]
				tipo_elegido = t
		conteo_tipos[tipo_elegido] += 1

		var casilla = matriz_tablero[coord_elegida]
		casilla.tipo_casilla = tipo_elegido
		casilla.scale = Vector2.ZERO
		casilla.queue_redraw()
		var tw = create_tween()
		tw.tween_property(casilla, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func terminar_turno(por_tiempo_agotado: bool = false):
	if modo_congelar:
		modo_congelar = false
		Global.monedas_jugadores[turno_actual] += 35
	deseleccionar_ficha_actual()
	ha_saltado_en_turno = false
	turno_pendiente_terminar = false
	if doble_jugada_activa and not por_tiempo_agotado:
		doble_jugada_activa = false
		actualizar_indicador_turno()
		label_turno.text = "2da Jugada: " + nombres_jugadores[turno_actual]
		return
	doble_jugada_activa = false
	
	for f in matriz_fichas.values():
		if f.jugador_id == turno_actual and f.congelada:
			f.set_congelada(false)
			
	contador_turnos_cajas += 1
	if contador_turnos_cajas % 4 == 0:
		generar_cajas_dinamicas(2)
		
	turno_actual = (turno_actual + 1) % num_jugadores_activo
	actualizar_indicador_turno()

func deseleccionar_ficha_actual():
	if ficha_seleccionada:
		ficha_seleccionada.set_seleccionada(false)
		ficha_seleccionada = null
		coord_seleccionada = Vector2(-1, -1)
	casillas_validas.clear()
	queue_redraw()

# --- SISTEMA DE PREGUNTAS ---
func crear_interfaz_pregunta():
	panel_pregunta = PanelContainer.new()
	panel_pregunta.z_index = 20
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
	
	tipo_pregunta_actual = tipo
	jugador_pregunta = turno_actual
	comodin_activo = false
	respondiendo_pregunta = false
	
	var titulo_recompensa = ""
	match tipo:
		"unidad_iii":
			recompensa_pendiente = 50
			titulo_recompensa = "RECOMPENSA: +50M"
		"cultura_general":
			recompensa_pendiente = 25
			titulo_recompensa = "RECOMPENSA: +25M"
		"cofre_sorpresa":
			recompensa_pendiente = 100
			titulo_recompensa = "🎁 ¡COFRE SORPRESA! 🎁"
		
	label_pregunta_texto.text = titulo_recompensa + "\n\n" + preg["pregunta"]
	label_pregunta_texto.add_theme_color_override("font_color", Color.WHITE)
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
	if respondiendo_pregunta:
		return
	respondiendo_pregunta = true
	boton_comodin.disabled = true
	
	var botones = vbox_respuestas.get_children()
	for i in range(botones.size()):
		botones[i].mouse_filter = Control.MOUSE_FILTER_IGNORE
		if i == respuesta_correcta_idx:
			botones[i].modulate = Color(0.35, 1.0, 0.45)
		elif i == idx:
			botones[i].modulate = Color(1.0, 0.35, 0.35)
			
	if idx == respuesta_correcta_idx:
		if sfx_correcto.stream: sfx_correcto.play()
		label_pregunta_texto.add_theme_color_override("font_color", Color(0.4, 1.0, 0.5))
		
		if tipo_pregunta_actual == "cofre_sorpresa":
			var sorteo = randi() % 3
			match sorteo:
				0:
					Global.monedas_jugadores[jugador_pregunta] += 120
					label_pregunta_texto.text = "🎁 ¡COFRE DE ORO!\n¡Ganaste +120 Monedas!"
				1:
					Global.monedas_jugadores[jugador_pregunta] += 50
					cargas_super_salto[jugador_pregunta] = cargas_super_salto.get(jugador_pregunta, 0) + 1
					label_pregunta_texto.text = "🎁 ¡PREMIO SORPRESA!\n+50 Monedas y +1 Súper Salto GRATIS (úsalo cuando quieras)"
				2:
					Global.monedas_jugadores[jugador_pregunta] += 60
					cargas_doble_jugada[jugador_pregunta] = cargas_doble_jugada.get(jugador_pregunta, 0) + 1
					label_pregunta_texto.text = "🎁 ¡PREMIO SORPRESA!\n+60 Monedas y +1 Doble Jugada GRATIS (úsala cuando quieras)"
		else:
			Global.monedas_jugadores[jugador_pregunta] += recompensa_pendiente
			label_pregunta_texto.text = "¡RESPUESTA CORRECTA!\n+" + str(recompensa_pendiente) + " Monedas"
			
		label_monedas.text = "Monedas: " + str(Global.monedas_jugadores[turno_actual])
		actualizar_texto_botones_habilidades()
	else:
		if sfx_error.stream: sfx_error.play()
		label_pregunta_texto.text = "¡RESPUESTA INCORRECTA!"
		label_pregunta_texto.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	
	await get_tree().create_timer(1.1 if tipo_pregunta_actual == "cofre_sorpresa" else 0.85).timeout
	panel_pregunta.hide()
	respondiendo_pregunta = false
	
	if turno_pendiente_terminar:
		turno_pendiente_terminar = false
		terminar_turno()

func activar_super_salto():
	if ha_saltado_en_turno or panel_pregunta.visible or respondiendo_pregunta:
		return
	if modo_super_salto:
		modo_super_salto = false
		if super_usado_gratis:
			cargas_super_salto[turno_actual] = cargas_super_salto.get(turno_actual, 0) + 1
			super_usado_gratis = false
		else:
			Global.monedas_jugadores[turno_actual] += 30
		label_monedas.text = "Monedas: " + str(Global.monedas_jugadores[turno_actual])
		actualizar_texto_botones_habilidades()
		actualizar_movimientos_validos()
		return

	if cargas_super_salto.get(turno_actual, 0) > 0:
		cargas_super_salto[turno_actual] -= 1
		super_usado_gratis = true
		modo_super_salto = true
		if sfx_compra.stream: sfx_compra.play()
		actualizar_texto_botones_habilidades()
		actualizar_movimientos_validos()
	elif Global.monedas_jugadores[turno_actual] >= 30:
		Global.monedas_jugadores[turno_actual] -= 30
		super_usado_gratis = false
		modo_super_salto = true
		if sfx_compra.stream: sfx_compra.play()
		label_monedas.text = "Monedas: " + str(Global.monedas_jugadores[turno_actual])
		actualizar_texto_botones_habilidades()
		actualizar_movimientos_validos()

func activar_doble_jugada():
	if panel_pregunta.visible or respondiendo_pregunta:
		return
	if doble_jugada_activa:
		doble_jugada_activa = false
		if doble_usado_gratis:
			cargas_doble_jugada[turno_actual] = cargas_doble_jugada.get(turno_actual, 0) + 1
			doble_usado_gratis = false
		else:
			Global.monedas_jugadores[turno_actual] += 45
		label_monedas.text = "Monedas: " + str(Global.monedas_jugadores[turno_actual])
		actualizar_texto_botones_habilidades()
		return

	if cargas_doble_jugada.get(turno_actual, 0) > 0:
		cargas_doble_jugada[turno_actual] -= 1
		doble_usado_gratis = true
		doble_jugada_activa = true
		if sfx_compra.stream: sfx_compra.play()
		actualizar_texto_botones_habilidades()
	elif Global.monedas_jugadores[turno_actual] >= 45:
		Global.monedas_jugadores[turno_actual] -= 45
		doble_usado_gratis = false
		doble_jugada_activa = true
		if sfx_compra.stream: sfx_compra.play()
		label_monedas.text = "Monedas: " + str(Global.monedas_jugadores[turno_actual])
		actualizar_texto_botones_habilidades()

func activar_congelar():
	if panel_pregunta.visible or respondiendo_pregunta:
		return
	if modo_congelar:
		modo_congelar = false
		Global.monedas_jugadores[turno_actual] += 35
		label_monedas.text = "Monedas: " + str(Global.monedas_jugadores[turno_actual])
		actualizar_texto_botones_habilidades()
		queue_redraw()
		return
	if Global.monedas_jugadores[turno_actual] >= 35:
		Global.monedas_jugadores[turno_actual] -= 35
		modo_congelar = true
		if sfx_compra.stream: sfx_compra.play()
		label_monedas.text = "Monedas: " + str(Global.monedas_jugadores[turno_actual])
		actualizar_texto_botones_habilidades()
		queue_redraw()

func usar_comodin():
	if Global.monedas_jugadores[jugador_pregunta] >= 20 and not comodin_activo and not respondiendo_pregunta:
		Global.monedas_jugadores[jugador_pregunta] -= 20
		comodin_activo = true
		if sfx_compra.stream: sfx_compra.play()
		label_monedas.text = "Monedas: " + str(Global.monedas_jugadores[turno_actual])
		boton_comodin.disabled = true
		var botones = vbox_respuestas.get_children()
		var eliminados = 0
		for i in range(botones.size()):
			if i != respuesta_correcta_idx and eliminados < 2:
				botones[i].disabled = true
				eliminados += 1

func crear_interfaz_victoria():
	cartel_victoria = PanelContainer.new()
	cartel_victoria.z_index = 30
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
	for id_jugador in casas_origen_jugador.keys():
		var casa_origen = casas_origen_jugador[id_jugador]
		var meta = casas_meta[casa_origen]
		var fichas_propias = 0
		var fichas_totales_en_meta = 0
		
		for coord in matriz_fichas.keys():
			if obtener_casa_id(coord) == meta:
				fichas_totales_en_meta += 1
				if matriz_fichas[coord].jugador_id == id_jugador:
					fichas_propias += 1
					
		# Gana si llenó las 10 casillas con sus fichas, o si ya metió al menos 7 fichas propias
		# y las casillas restantes de su meta están bloqueadas por fichas rivales (regla anti-bloqueo).
		if fichas_totales_en_meta == 10 and fichas_propias >= 7:
			lanzar_victoria(id_jugador)
			return
