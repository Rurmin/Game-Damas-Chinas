# Damas Chinas Adaptativo

Un juego de mesa interactivo y adaptativo desarrollado en **Godot Engine 4**, que combina la estrategia clásica de las **Damas Chinas** con retos académicos de **Teoría Combinatoria / Conteo (Unidad III)** y preguntas de **Cultura General**. Cuenta con aparición equitativa y dinámica de objetos por sectores, tienda de habilidades activables a voluntad, múltiples modos de juego (2, 3, 4 y 6 jugadores), escenarios ilustrados en pantalla completa y retroalimentación visual y sonora.

---

## 🚀 Características Principales

* **Lógica Completa de Estrella de 6 Puntas:** Soporte simétrico para partidas de **2, 3, 4 y 6 jugadores**, con cálculo de pasos adyacentes, saltos en cadena, guías visuales de destinos válidos, anillos brillantes en la casa meta de cada jugador y regla anti-bloqueo en la meta.
* **Sistema de Preguntas Barajadas (Sin Repetición):** Amplio banco de preguntas con barajado automático tanto del mazo como del orden de las opciones de respuesta, con retroalimentación visual inmediata (verde/rojo).
* **Aparición Equitativa y Reaparición Dinámica de Cajas:** El hexágono central se divide en **6 sectores angulares** para garantizar que todos los jugadores tengan la misma cantidad de cajas cercanas y que siempre aparezcan los **3 tipos de objetos** en el tablero, regenerándose dinámicamente cada 4 turnos en los sectores menos poblados.
* **Tienda de Poderes Activables a Voluntad:**
  * 🚀 **Súper Salto (30 Monedas):** Permite realizar un salto especial de largo alcance (hasta 4 casillas de distancia). Se puede activar o cancelar antes de mover, o acumular cargas gratuitas obtenidas en Cofres Sorpresa.
  * ⚡ **Doble Jugada (45 Monedas):** Otorga un segundo movimiento consecutivo en el mismo turno para construir y cruzar puentes propios.
  * ❄️ **Congelar Rival (35 Monedas):** Congela una ficha enemiga durante 1 turno completo con efecto visual de escarcha y sonido especial, impidiendo que el rival la mueva.
  * 💡 **Comodín 50/50 (20 Monedas):** Elimina dos opciones incorrectas durante una pregunta activa.
* **Temporizador de Turno Ajustable:** Opciones de **15s, 30s, 60s o Sin Límite**, además de botón dedicado para **Pasar Turno / Finalizar Salto ✔**.
* **Escenarios Ilustrados en Pantalla Completa:**
  * 🌅 *Atardecer Imperial* (`mapa_0.png`)
  * 🌙 *Noche Mística* (`mapa_1.png`)

---

## 🛠️ Casillas Especiales

| Icono | Tipo de Casilla | Recompensa | Descripción |
| :---: | :--- | :---: | :--- |
| 🌟 | **Unidad III (Estrellas)** | **+50 M** | Retos sobre Teoría de Conteo, Permutaciones, Combinaciones y Variaciones. |
| 📘 | **Cultura General** | **+25 M** | Preguntas variadas de ciencia, historia, arte y geografía. |
| 🎁 | **Cofre Sorpresa** | **Premio Aleatorio** | Al acertar, otorga al azar **+120 Monedas**, **+50 M y 1 Súper Salto GRATIS** o **+60 M y 1 Doble Jugada GRATIS**. |

---

## 🔊 Integración de Audio

El proyecto incluye música ambiental y efectos de sonido dedicados:

* **`musica_fondo.mp3`**: Música ambiental del menú principal con control de volumen general y opción de silencio.
* **`fichasonido.mp3`**: Sonido al realizar un paso o salto normal en el tablero.
* **`supersalto.mp3`**: Efecto especial al desplazarse usando el Súper Salto.
* **`compra.mp3`**: Sonido al adquirir o activar un poder de la tienda o el comodín 50/50.
* **`congelar.mp3`**: Efecto de hielo al congelar una ficha rival.
* **`correcto.mp3`**: Retroalimentación al acertar una pregunta.
* **`error.mp3`**: Retroalimentación al fallar una pregunta, intentar mover una ficha congelada o agotar el tiempo.
* **`victoria.mp3`**: Fanfarria al proclamarse ganador de la partida.

---

## 📁 Estructura del Proyecto

```text
├── assets/
│   ├── boton_salir.png
│   ├── casilla_cofre.png
│   ├── casilla_cultura.png
│   ├── casilla_unidad_iii.png
│   ├── compra.mp3
│   ├── congelar.mp3
│   ├── correcto.mp3
│   ├── error.mp3
│   ├── fichasonido.mp3
│   ├── fondo_menu.jpg
│   ├── mapa_0.png (Atardecer Imperial)
│   ├── mapa_1.png (Noche Mística)
│   ├── marco_titulo.png
│   ├── pergamino_ui.jpg
│   ├── supersalto.mp3
│   ├── titulo_ajustes.png
│   ├── titulo_audio.png
│   ├── titulo_como_jugar.png
│   ├── titulo_principal.png
│   └── victoria.mp3
├── data/
│   └── musica_fondo.mp3
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
    ├── ficha.gd
    └── preguntas.gd
```

---

## ⚙️ Requisitos e Instalación

1. **Motor de Desarrollo:** Godot Engine v4.x (Soporte 2D).
2. **Ejecución:**
   * Clona este repositorio:
     ```bash
     git clone https://github.com/Rurmin/Game-Damas-Chinas
     ```
   * Importa el proyecto en Godot Engine seleccionando el archivo `project.godot`.
   * Presiona **`F5`** para iniciar el juego en pantalla completa.
