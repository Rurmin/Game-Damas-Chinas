# Damas Chinas Adaptativo

Un juego de mesa interactivo y adaptativo desarrollado en **Godot Engine**, que combina la mecánica clásica de las Damas Chinas con preguntas académicas sobre **Estructuras Dinámicas / Teoría Combinatoria (Unidad III)** y preguntas de **Cultura General**. Incluye un sistema de recompensas, tienda de potenciadores, configuración de tiempo por turno, dualidad de entornos gráficos y retroalimentación sonora personalizada.

---

## 🚀 Características Principales

* **Lógica Completa de Damas Chinas:** Gestión de turnos dinámicos para 2, 3, 4 y 6 jugadores, con cálculo de pasos adyacentes, cadenas de saltos y detección automática de condición de victoria en la casa opuesta.
* **Sistema de Preguntas y Monedas:** Al caer en casillas especiales, se despliega una ventana interactiva con preguntas. Responder correctamente otorga monedas que se acumulan en el perfil del jugador.
* **Tienda de Potenciadores:**
* **Súper Salto (30 Monedas):** Permite realizar un movimiento especial de largo alcance (hasta 4 casillas de distancia en línea recta).
* **Comodín 50/50 (20 Monedas):** Elimina dos opciones incorrectas durante la ventana de preguntas.


* **Temporizador de Turno Ajustable:** Opciones de límite de tiempo (15s, 30s, 60s o Sin Límite). Si el tiempo se agota, el turno se transfiere automáticamente al siguiente jugador con retroalimentación de error.
* **Dualidad de Ambientes (Mapas):** Selección de escenario desde el menú de opciones:
* *Atardecer Oriental* (`mapa_0.jpg` / `mapa_0.png`)
* *Noche Mística* (`mapa_1.png`)


* **Interfaz Dinámica de Victoria:** Cartel conmemorativo al completar las 10 fichas en la meta, ajustando el color de fondo al color asignado al jugador ganador.

---

## 🛠️ Casillas Especiales

| Icono | Tipo de Casilla | Recompensa | Descripción |
| --- | --- | --- | --- |
| 🌟 | **Unidad III** | **+50 M** | Preguntas académicas sobre Teoría de Conteo, Permutaciones, Combinaciones y Variaciones. |
| 📘 | **Cultura General** | **+25 M** | Preguntas de conocimientos generales. |
| 🎁 | **Cofre Sorpresa** | **+100 M** | Preguntas rápidas de recompensa alta. |

---

## 🔊 Integración de Audio

El proyecto incluye reproductores asignados a eventos específicos utilizando la API de Audio de Godot:

* **`fichasonido.mp3`**: Reproduce el sonido de movimiento al desplazar o saltar con una ficha normal.
* **`supersalto.mp3`**: Suena al ejecutar el movimiento especial de Súper Salto.
* **`correcto.mp3`**: Retroalimentación sonora al acertar una pregunta en el panel flotante.
* **`error.mp3`**: Suena al fallar una pregunta o al agotarse el tiempo del turno.
* **`victoria.mp3`**: Fanfarria que se activa al desplegar la pantalla de ganador.

---

## 🔑 Atajos de Desarrollador (Debug Shortcuts)

Para facilitar la prueba de mecánicas y la demostración del proyecto:

* **Tecla `M**`: Otorga **+100 Monedas** instantáneas al jugador en turno para probar la tienda y comodines.
* **Tecla `V**`: Despliega la pantalla de **Victoria Instantánea** para el jugador en turno.

---

## 📁 Estructura del Proyecto

```text
├── assets/
│   ├── casilla_unidad_iii.png
│   ├── casilla_cultura.png
│   ├── casilla_cofre.png
│   ├── marco_titulo.png
│   ├── mapa_0.jpg (Atardecer)
│   ├── mapa_1.png (Noche Mística)
│   ├── fichasonido.mp3
│   ├── supersalto.mp3
│   ├── correcto.mp3
│   ├── error.mp3
│   └── victoria.mp3
├── scenes/
│   ├── menu_principal.tscn
│   ├── Tablero.tscn
│   ├── casilla.tscn
│   └── ficha.tscn
└── scripts/
    ├── global.gd
    ├── menu_principal.gd
    ├── tablero.gd
    ├── casilla.gd
    └── preguntas.gd

```

---

## ⚙️ Requisitos e Instalación

1. **Motor de Desarrollo:** Godot Engine v4.x (Soporte 2D).
2. **Ejecución:**
* Clona este repositorio:
```bash
git clone (https://github.com/Rurmin/Game-Damas-Chinas)

```


* Importa el proyecto en Godot Engine seleccionado el archivo `project.godot`.
* Presiona **`F5`** para iniciar la ejecución del proyecto.
