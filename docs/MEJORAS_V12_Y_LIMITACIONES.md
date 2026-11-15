# MISSION: UNKNOWN V12 — qué cambió y qué NO se debe prometer

## Cambios principales
- Se conserva el diseño y la navegación del juego V11.1, pero se actualiza `UI.page()` para fijar cabecera y pie. El cuerpo central desplaza con ScrollContainer al crecer; es posible ver botones en 1280×720.
- El **análisis forense NASA** aparece también cuando una misión termina con derrota. El jugador estudia publicaciones públicas NASA, **sin obtener datos de una nave ficticia destruida**. Los puntos pedagógicos se separan de `science_review` y no aumentan la nota de la misión perdida.
- Nuevo **laboratorio de datos**: selecciona Luna, Venus o Marte y modifica la distancia orbital hipotética entre 0.5 y 2 UA. Se calculan irradiancias con una ley física verificable, tiempos ideales y cotas aproximadas de retardo radio. Es offline, reproducible y las cifras corresponden a modelos simplificados.
- Catálogo PDS (`data/nasa_pds_catalog.json`) para localizar observaciones archivadas de LRO, Magellan y MRO. El proyecto no hace pasar los resúmenes por productos crudos PDS.
- El centro de control aclara la latencia radio aproximada y separa los retrasos ficticios del modelo Hohmann ideal.
- Pruebas nativas complementarias de fuentes y comprobación de interfaz, pendientes de ejecución en un equipo con Godot.

## Límite científico
Los semiejes mayores son valores de referencia JPL, no posiciones actuales. `F(r)=1360.8/(r/UA)^2` utiliza irradiancia normal a la incidencia solar. Las cotas del tiempo de luz entre planetas suponen órbitas circulares coplanares: no son efemérides, no son latencia actual ni contacto real DSN. El Hohmann usa dos cuerpos y órbitas circulares, sin ventanas, cambio de plano, encuentro ni inserción orbital.

La puntuación, distancia educativa, daños y recursos son reglas lúdicas. Los parámetros de masa, tanque e impulso específico de la ecuación del cohete son hipótesis de diseño, NO especificaciones de un vehículo de NASA.

## Referencias y archivos
- https://ssd.jpl.nasa.gov/planets/approx_pos.html — parámetros orbitales aproximados
- https://science.nasa.gov/moon/facts/ — distancia lunar media
- https://www.jpl.nasa.gov/edu/resources/lesson-plan/calculating-solar-power-in-space/ — inverso del cuadrado e irradiancia
- https://ode.rsl.wustl.edu/ — repositorio PDS ODE con LRO, Magellan y MRO
- https://planetary.data.nasa.gov/find-data — índice NASA de archivos científicos

## Evaluación de impacto
El cuestionario paralelo de 4 preguntas es una medición INDIVIDUAL, no demuestra causalidad. Para medir utilidad educativa: reclutar participantes voluntarios, registrar puntajes previos y posteriores sin identificadores, mantener la misma instrucción y duración, verificar que las dos versiones del test tienen dificultad comparable y reportar media, dispersión y muestra. No inventar resultados de usuarios.

## Validación reproducible
1. `godot --headless --path . --script res://tests/test_suite.gd`
2. `godot --headless --path . --script res://tests/test_v12_features.gd`
3. `godot --headless --path . --script res://tests/ui_smoke_v12.gd` (prueba temporal; no modifica el guardado)
4. Ejecutar F5 a 1280×720 y comprobar los 12+1 escenarios, todas las opciones, un triunfo, una derrota, el análisis forense, exportar informe y botones tras desplazamiento.

**Nota:** la creación del ZIP y las verificaciones Python NO implican que estas pruebas de Godot se hayan ejecutado aquí.
