extends Node

# Banco de preguntas
var banco = {
	"unidad_iii": [
		{ "pregunta": "¿En qué técnica importa el orden de los elementos?", "opciones": ["Combinación", "Permutación", "Adición", "Sustracción"], "correcta": 1 },
		{ "pregunta": "¿Qué rama de las matemáticas estudia la Teoría de Conteo?", "opciones": ["Geometría", "Álgebra", "Combinatoria", "Cálculo"], "correcta": 2 },
		{ "pregunta": "Si lanzas una moneda y un dado, ¿qué principio de conteo usas para saber los resultados posibles?", "opciones": ["Adición", "Sustracción", "División", "Multiplicación"], "correcta": 3 },
		{ "pregunta": "¿Cómo se llama cuando se ordenan elementos en un círculo?", "opciones": ["Permutación Circular", "Variación lineal", "Combinación cíclica", "Ordenamiento base"], "correcta": 0 },
		{ "pregunta": "¿Cuánto vale el factorial de cero (0!)?", "opciones": ["0", "1", "No existe", "Infinito"], "correcta": 1 },
		{ "pregunta": "¿Cuánto es 4! (cuatro factorial)?", "opciones": ["12", "16", "24", "4"], "correcta": 2 },
		{ "pregunta": "Si eliges 3 frutas para un batido sin importar el orden, ¿qué estás usando?", "opciones": ["Combinación", "Permutación", "Factorial simple", "Regla de Laplace"], "correcta": 0 },
		{ "pregunta": "¿De cuántas formas distintas pueden sentarse 3 personas en una fila de 3 sillas?", "opciones": ["3", "6", "9", "12"], "correcta": 1 },
		{ "pregunta": "¿Cuál es la fórmula de la permutación circular de n elementos?", "opciones": ["n!", "(n - 1)!", "n / 2", "n! / 2"], "correcta": 1 },
		{ "pregunta": "Si tienes 3 camisas y 4 pantalones, ¿cuántos atuendos distintos puedes formar?", "opciones": ["7", "12", "16", "9"], "correcta": 1 },
		{ "pregunta": "¿Qué diagrama se utiliza frecuentemente para visualizar todos los resultados posibles de un experimento?", "opciones": ["Diagrama de Árbol", "Histograma", "Gráfico Pastel", "Plano Cartesiano"], "correcta": 0 },
		{ "pregunta": "Si dos eventos no pueden ocurrir al mismo tiempo, ¿qué principio se aplica para contar sus opciones?", "opciones": ["Principio de Adición", "Principio de Multiplicación", "Permutación con repetición", "Factorial"], "correcta": 0 },
		{ "pregunta": "¿Cuántos resultados posibles hay al lanzar una moneda 3 veces seguidas?", "opciones": ["6", "8", "9", "4"], "correcta": 1 },
		{ "pregunta": "¿De cuántas maneras se pueden elegir 2 representantes de un grupo de 5 personas?", "opciones": ["10", "20", "25", "5"], "correcta": 0 },
		{ "pregunta": "En una carrera de 5 corredores, ¿de cuántas formas pueden repartirse el 1° y 2° lugar?", "opciones": ["10", "20", "25", "15"], "correcta": 1 }
	],
	"cultura_general": [
		{ "pregunta": "¿Cuál es el planeta más grande del sistema solar?", "opciones": ["Marte", "Tierra", "Júpiter", "Saturno"], "correcta": 2 },
		{ "pregunta": "¿Qué animal es el mejor amigo del hombre?", "opciones": ["Gato", "Perro", "Caballo", "Loro"], "correcta": 1 },
		{ "pregunta": "¿Cuántos días tiene un año bisiesto?", "opciones": ["364", "365", "366", "367"], "correcta": 2 },
		{ "pregunta": "¿En qué país se originó realmente el juego de las Damas Chinas?", "opciones": ["China", "Alemania", "Japón", "Egipto"], "correcta": 1 },
		{ "pregunta": "¿Cuál es el océano más grande del planeta Tierra?", "opciones": ["Atlántico", "Índico", "Pacífico", "Ártico"], "correcta": 2 },
		{ "pregunta": "¿Qué gas respiramos que es esencial para la vida humana?", "opciones": ["Oxígeno", "Helio", "Dióxido de carbono", "Hidrógeno"], "correcta": 0 },
		{ "pregunta": "¿Cuántos continentes existen tradicionalmente en el mundo?", "opciones": ["4", "5", "6", "8"], "correcta": 2 },
		{ "pregunta": "¿Cuál es el metal líquido a temperatura ambiente?", "opciones": ["Hierro", "Mercurio", "Cobre", "Aluminio"], "correcta": 1 },
		{ "pregunta": "¿Quién pintó la famosa obra 'La Mona Lisa'?", "opciones": ["Pablo Picasso", "Vincent van Gogh", "Leonardo da Vinci", "Miguel Ángel"], "correcta": 2 },
		{ "pregunta": "¿Cuál es el río más caudaloso del mundo?", "opciones": ["Nilo", "Amazonas", "Misisipi", "Yangtsé"], "correcta": 1 },
		{ "pregunta": "¿Cuántos huesos tiene aproximadamente el cuerpo humano adulto?", "opciones": ["150", "206", "300", "108"], "correcta": 1 },
		{ "pregunta": "¿Cuál es el planeta más cercano al Sol?", "opciones": ["Venus", "Mercurio", "Marte", "Tierra"], "correcta": 1 },
		{ "pregunta": "¿Qué instrumento mide los terremotos?", "opciones": ["Termómetro", "Barómetro", "Sismógrafo", "Telescopio"], "correcta": 2 },
		{ "pregunta": "¿Cuál es el animal terrestre más veloz?", "opciones": ["León", "Guepardo", "Caballo", "Águila"], "correcta": 1 },
		{ "pregunta": "¿Cuál es el elemento químico representado por el símbolo 'Au'?", "opciones": ["Plata", "Oro", "Cobre", "Argón"], "correcta": 1 }
	],
	"cofre_sorpresa": [
		{ "pregunta": "Rápido: ¿Cuánto es 5 x 5?", "opciones": ["20", "25", "30", "15"], "correcta": 1 },
		{ "pregunta": "Rápido: ¿Qué color sale de mezclar azul y amarillo?", "opciones": ["Verde", "Naranja", "Morado", "Rojo"], "correcta": 0 },
		{ "pregunta": "Rápido: ¿Cuántas patas tiene una araña?", "opciones": ["6", "8", "10", "4"], "correcta": 1 },
		{ "pregunta": "Rápido: ¿Cuántas puntas tiene la estrella del tablero de Damas Chinas?", "opciones": ["5", "6", "8", "4"], "correcta": 1 },
		{ "pregunta": "Rápido: ¿Cuánto es 9 x 8?", "opciones": ["72", "64", "81", "68"], "correcta": 0 },
		{ "pregunta": "Rápido: ¿Cuántos minutos tiene una hora y media?", "opciones": ["80", "90", "100", "75"], "correcta": 1 },
		{ "pregunta": "Rápido: ¿Cuál es la raíz cuadrada de 49?", "opciones": ["6", "7", "8", "9"], "correcta": 1 },
		{ "pregunta": "Rápido: ¿Cuántas fichas tiene cada jugador en Damas Chinas?", "opciones": ["8", "10", "12", "15"], "correcta": 1 },
		{ "pregunta": "Rápido: ¿Cuánto es la mitad de 150?", "opciones": ["65", "75", "85", "70"], "correcta": 1 },
		{ "pregunta": "Rápido: ¿Cuántos lados tiene un hexágono?", "opciones": ["5", "6", "7", "8"], "correcta": 1 },
		{ "pregunta": "Rápido: ¿Qué número sigue en la serie 2, 4, 8, 16...?", "opciones": ["24", "32", "20", "30"], "correcta": 1 },
		{ "pregunta": "Rápido: ¿Cuánto es 100 - 37?", "opciones": ["63", "73", "67", "53"], "correcta": 0 }
	]
}

var mazos_disponibles = {}

func obtener_pregunta_aleatoria(tipo: String) -> Dictionary:
	if not banco.has(tipo) or banco[tipo].is_empty():
		return {}
	
	if not mazos_disponibles.has(tipo) or mazos_disponibles[tipo].is_empty():
		var copia = banco[tipo].duplicate(true)
		copia.shuffle()
		mazos_disponibles[tipo] = copia
		
	var preg = mazos_disponibles[tipo].pop_back().duplicate(true)
	var texto_correcto = preg["opciones"][preg["correcta"]]
	preg["opciones"].shuffle()
	preg["correcta"] = preg["opciones"].find(texto_correcto)
	return preg