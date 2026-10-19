extends Node2D

var jugador_id : int = 0
var color_ficha : Color = Color.RED
var seleccionada : bool = false
var congelada : bool = false

var radio : float = 11.0 

func set_jugador(id: int) -> void:
	jugador_id = id
	match id:
		0: color_ficha = Color(0.22, 0.85, 0.22) # 0: Verde (Norte)[cite: 29]
		1: color_ficha = Color(0.95, 0.85, 0.2)  # 1: Amarillo (Noreste)[cite: 29]
		2: color_ficha = Color(0.7, 0.3, 0.8)    # 2: Violeta (Sureste)[cite: 29]
		3: color_ficha = Color(0.9, 0.9, 0.9)    # 3: Blanco (Sur)[cite: 29]
		4: color_ficha = Color(0.92, 0.22, 0.22) # 4: Rojo (Suroeste)[cite: 29]
		5: color_ficha = Color(0.2, 0.6, 0.9)    # 5: Azul (Noroeste)[cite: 29]
		_: color_ficha = Color.RED
	queue_redraw()

func set_seleccionada(estado: bool) -> void:
	seleccionada = estado
	queue_redraw()

func set_congelada(estado: bool) -> void:
	congelada = estado
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2(0, 1.5), radio, Color(0, 0, 0, 0.35))
	draw_circle(Vector2.ZERO, radio, color_ficha)
	draw_circle(Vector2(-radio * 0.3, -radio * 0.3), radio * 0.3, Color(1, 1, 1, 0.45))
	if congelada:
		draw_circle(Vector2.ZERO, radio, Color(0.55, 0.92, 1.0, 0.55))
		draw_arc(Vector2.ZERO, radio + 2.5, 0, TAU, 32, Color(0.25, 0.95, 1.0, 0.95), 3.0, true)
	elif seleccionada:
		draw_arc(Vector2.ZERO, radio + 2.0, 0, TAU, 32, Color.YELLOW, 2.5, true)
	else:
		draw_arc(Vector2.ZERO, radio, 0, TAU, 32, Color(0, 0, 0, 0.5), 1.2, true)