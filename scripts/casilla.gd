extends Area2D

signal casilla_seleccionada(posicion_coordenada)

var coordenadas : Vector2 = Vector2.ZERO
var tipo_casilla : String = "normal" 

var tex_unidad_iii = preload("res://assets/casilla_unidad_iii.png")
var tex_cultura = preload("res://assets/casilla_cultura.png")
var tex_cofre = preload("res://assets/casilla_cofre.png")

func _ready() -> void:
	input_pickable = true

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		emit_signal("casilla_seleccionada", coordenadas)
		
func _draw():
	match tipo_casilla:
		"unidad_iii":
			if tex_unidad_iii:
				# Tamaño súper aumentado (36x36)
				draw_texture_rect(tex_unidad_iii, Rect2(-18, -18, 36, 36), false) 
			else:
				draw_circle(Vector2.ZERO, 10, Color.YELLOW)
		"cultura_general": # Nombre corregido
			if tex_cultura:
				draw_texture_rect(tex_cultura, Rect2(-18, -18, 36, 36), false)
			else:
				draw_circle(Vector2.ZERO, 10, Color.LIGHT_BLUE)
		"cofre_sorpresa": # Nombre corregido
			if tex_cofre:
				draw_texture_rect(tex_cofre, Rect2(-18, -18, 36, 36), false)
			else:
				draw_rect(Rect2(-10, -10, 20, 20), Color.GOLD)