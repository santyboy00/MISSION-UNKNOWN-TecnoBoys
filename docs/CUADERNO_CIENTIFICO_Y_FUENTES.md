# Cuaderno científico para jurado — MISSION: UNKNOWN V11

## Datos verificables y modelos

| Dato/fórmula | Uso en el juego | Referencia | Clasificación |
|---|---|---|---|
| Semiejes mayores: Venus 0.72333566 UA; Marte 1.52371034 UA | Transferencia ideal | https://ssd.jpl.nasa.gov/planets/approx_pos.html | JPL |
| Distancia media a la Luna 384 400 km | Latencia unidireccional media geométrica | https://science.nasa.gov/moon/facts/ | NASA |
| Hohmann a Venus y Marte | Duración mínima ideal, no calendario de vuelo | https://science.nasa.gov/learn/basics-of-space-flight/chapter3-2/ | Modelo de dos cuerpos |
| Tsiolkovski Δv=Isp*g0*ln(m0/mf) | Capacidad de maniobra orientativa | https://science.nasa.gov/learn/basics-of-space-flight/chapter3-2/ | Fórmula real + masas hipotéticas |
| Red DSN: Goldstone/Madrid/Canberra | Justificación de segmento terrestre | https://science.nasa.gov/learn/basics-of-space-flight/chapter18-1/ | NASA |
| NASA LRO/LEND, LROC, LCROSS | 3 casos interpretativos Luna | https://science.nasa.gov/mission/lro/spacecraft-and-instruments/ | Resúmenes NASA |
| NASA Magellan, Venus Facts | 3 casos interpretativos Venus | https://science.nasa.gov/mission/magellan/ | Resúmenes NASA |
| NASA MRO/CRISM, HiRISE, SHARAD | 3 casos interpretativos Marte | https://science.nasa.gov/mission/mars-reconnaissance-orbiter/science-instruments/ | Resúmenes NASA |

## Qué NO afirmamos

- No modelamos cuerpos perturbados, efemérides/ventanas reales ni un perfil de inserción orbital certificado.
- La curva visual Bézier no es una trayectoria resuelta por GMAT.
- Las lecturas de 10 eventos, presupuestos y porcentajes de derrota son reglas pedagógicas creadas por el equipo.
- Las preguntas interpretativas usan **resúmenes de hallazgos publicados**, no matrices de píxeles, radiometría ni descarga en tiempo real de PDS.
- Los planes de DSN no son reservas reales de estaciones ni garantizan cobertura.

## Calibración que falta antes de reclamar alta validez científica

1. Contrastar tiempo y maniobras con ejemplos publicados por NASA/JPL o GMAT.
2. Añadir un caso de imágenes/mediciones reales descargadas del PDS si se requiere procesar datos crudos.
3. Ejecutar todas las escenas en Godot 4.5 con registro de errores y pruebas de interacción a 1280×720.
4. Realizar pretest y postest con participantes voluntarios y reportar tamaño de muestra y distribución, no resultados inventados.

## Declaración de asistencia

Es recomendable documentar claramente el uso de herramientas de IA y la intervención humana en diseño, programación, revisión y validación. No declarar como desarrolladas o ensayadas manualmente partes que nadie ha verificado.
