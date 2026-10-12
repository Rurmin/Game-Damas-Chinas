extends Node

# Banco de preguntas
var banco = {
	"unidad_iii": [
		{ "pregunta": "¿En qué técnica importa el orden de los elementos?", "opciones": ["Combinación", "Permutación", "Adición", "Sustracción"], "correcta": 1 },
		{ "pregunta": "¿Qué rama de las matemáticas estudia la Teoría de Conteo?", "opciones": ["Geometría", "Álgebra", "Combinatoria", "Cálculo"], "correcta": 2 },
		{ "pregunta": "Si lanzas una moneda y un dado, ¿qué principio de conteo usas para saber los resultados posibles?", "opciones": ["Adición", "Sustracción", "División", "Multiplicación"], "correcta": 3 },
		{ "pregunta": "¿Cómo se llama cuando se ordenan elementos en un círculo?", "opciones": ["Permutación Circular", "Variación lineal", "Combinación cíclica", "Ordenamiento base"], "correcta": 0 }
	],
	"cultura_general": [
		{ "pregunta": "¿Cuál es el planeta más grande del sistema solar?", "opciones": ["Marte", "Tierra", "Júpiter", "Saturno"], "correcta": 2 },
		{ "pregunta": "¿Qué animal es el mejor amigo del hombre?", "opciones": ["Gato", "Perro", "Caballo", "Loro"], "correcta": 1 },
		{ "pregunta": "¿Cuántos días tiene un año bisiesto?", "opciones": ["364", "365", "366", "367"], "correcta": 2 }
	],
	"cofre_sorpresa": [
		{ "pregunta": "Rápido: ¿Cuánto es 5 x 5?", "opciones": ["20", "25", "30", "15"], "correcta": 1 },
		{ "pregunta": "Rápido: ¿Qué color sale de mezclar azul y amarillo?", "opciones": ["Verde", "Naranja", "Morado", "Rojo"], "correcta": 0 },
		{ "pregunta": "Rápido: ¿Cuántas patas tiene una araña?", "opciones": ["6", "8", "10", "4"], "correcta": 1 }
	]
}

func obtener_pregunta_aleatoria(tipo: String) -> Dictionary:
	if banco.has(tipo) and banco[tipo].size() > 0:
		var index = randi() % banco[tipo].size()
		return banco[tipo][index]
	return {}