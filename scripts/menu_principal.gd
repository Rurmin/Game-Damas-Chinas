extends Control

# Referencias a los nodos de tu escena
@onready var ventana_reglas = $VentanaReglas
@onready var boton_jugar = $ContenedorBotones/BotonJugar
@onready var boton_como_jugar = $ContenedorBotones/BotonComoJugar
@onready var boton_opciones = $ContenedorBotones/BotonOpciones
@onready var boton_cerrar_reglas = $VentanaReglas/BotonCerrar

func _ready():
	# 1. Aseguramos que la ventana empiece oculta al arrancar el juego
	if ventana_reglas:
		ventana_reglas.hide()
	
	# 2. Conectamos los clics de los botones a sus funciones
	if boton_jugar:
		boton_jugar.pressed.connect(_on_boton_jugar_pressed)
		
	if boton_como_jugar:
		boton_como_jugar.pressed.connect(_on_boton_como_jugar_pressed)
		
	if boton_cerrar_reglas:
		boton_cerrar_reglas.pressed.connect(_on_boton_cerrar_reglas_pressed)

# --- ACCIONES DE LOS BOTONES ---

func _on_boton_jugar_pressed():
	print("¡Iniciando juego!")

func _on_boton_como_jugar_pressed():
	if ventana_reglas:
		ventana_reglas.show()

func _on_boton_cerrar_reglas_pressed():
	if ventana_reglas:
		ventana_reglas.hide()