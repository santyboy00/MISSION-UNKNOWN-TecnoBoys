# Guía de modificación en Godot 4.5 (para principiantes)

## Mapa de escenas

- `main_menu.tscn`: menú, tutorial, pretest, datos NASA y nueva misión.
- `mission_select.tscn`: Luna/Venus/Marte, nombre de equipo y 1–4 participantes locales.
- `engineering.tscn`: módulos, lanzador, órbita y plan terrestre. Opciones actualizan `GameData`.
- `laboratory.tscn`: seis verificaciones de diseño.
- `launch.tscn`: cohete en `launch_view.gd` animado por código.
- `flight.tscn`: diez incidentes, voto local, telemetría y ruta animada por `trajectory_view.gd`.
- `science_analysis.tscn`: tres investigaciones NASA dependientes del equipamiento.
- `results.tscn`: resumen, derrota y MISSION REWIND.
- `debrief.tscn`: bitácora exportable a `user://informe_mission_unknown.txt`.
- `nasa_sources.tscn`: cifras NASA/JPL y enlaces.
- `knowledge_lab.tscn`: pruebas paralelas A/B antes/después.
- `tutorial.tscn`: reglas y ayuda.

## Modifica un componente

En `scripts/mission_data.gd`, cambia `cost`, `mass`, `consumption`, `generation` o `science`. Son **unidades educativas**: no afirmes que son especificaciones NASA. El gráfico de la nave se dibuja en `scripts/ship_view.gd`. La nueva decisión debe validarse en `scripts/simulation.gd`.

## Modifica una decisión

`mission_data.gd` contiene `EVENTS`, con título, descripción, 3 opciones y `effects`. `simulation.gd` aplica los efectos, controla energía, señal, integridad, combustible, ruta y fracaso.

## Modifica evidencia NASA

Edita `data/science_evidence_nasa.json`: cada registro indica misión científica publicada, observación resumida, pregunta, 3 opciones, `answer` (0–2), instrumento necesario y `source` oficial. No inventar observaciones ni atribuir al jugador una misión histórica.

## Modifica la interfaz sin encimar textos

Trabaja sobre `scripts/ui_kit.gd`: `UI.page`, `UI.panel`, `UI.row` y `UI.column` utilizan contenedores; evita posicionar manualmente las etiquetas. Si se llena un panel, usa `UI.scroll_column`.

## Pruebas

En el directorio del proyecto ejecuta:

`godot --headless --path . --script res://tests/test_suite.gd`

Necesitas instalar Godot. En `tests/validacion_matematica.py` hay un validador independiente para las fórmulas y rutas.
