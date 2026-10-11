extends Node2D

# Cargamos el molde de la casilla desde su carpeta
var casilla_escena = preload("res://scenes/casilla.tscn")
var matriz_tablero = {}

func _ready() -> void:
	print("Generando estrella de 121 casillas...")
	
	# Cantidad de casillas por cada una de las 17 filas de la estrella
	var filas = [
		1, 2, 3, 4,          # Triángulo superior (Casa 1)
		13, 12, 11, 10, 9,   # Mitad superior del centro
		10, 11, 12, 13,      # Mitad inferior del centro
		4, 3, 2, 1           # Triángulo inferior (Casa 2)
	]
	
	# Recorremos cada fila para armar el tablero
	for fila in range(filas.size()):
		var casillas_en_fila = filas[fila]
		
		# Calculamos el margen para que la fila quede centrada
		var offset_centrado = (13 - casillas_en_fila) / 2.0
		
		# Dibujamos las casillas de esa fila
		for columna in range(casillas_en_fila):
			var pos_x_visual = columna + offset_centrado
			crear_casilla(pos_x_visual, fila, columna)

func crear_casilla(pos_x_visual: float, fila_y: int, indice_columna: int):
	var nueva_casilla = casilla_escena.instantiate()
	var espaciado = 40 # Tamaño de separación entre casillas
	
	# Posición real centrada en la pantalla
	var pos_x = 316 + (pos_x_visual * espaciado)
	var pos_y = 20 + (fila_y * (espaciado * 0.866))
	
	nueva_casilla.position = Vector2(pos_x, pos_y)
	add_child(nueva_casilla)
	
	# Guardamos la posición lógica
	matriz_tablero[Vector2(indice_columna, fila_y)] = nueva_casilla
