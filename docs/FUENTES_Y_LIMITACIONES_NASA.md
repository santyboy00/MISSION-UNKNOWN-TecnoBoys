# MISSION: UNKNOWN V10 — fuentes, cálculos y limitaciones

**Proyecto educativo independiente, no afiliado ni respaldado por NASA.** Las cifras reales se distinguen de los parámetros didácticos.

## Entradas publicadas por NASA/JPL

- **Luna**: distancia media geocéntrica de **384 400 km** (NASA Science), no una distancia exacta en una fecha específica. https://science.nasa.gov/moon/facts/
- **Luna (referencia Apollo)**: viaje de aproximadamente **3 días** en misiones Apollo. Es una duración histórica de referencia, no una solución de transferencia calculada para cualquier sonda. https://science.nasa.gov/resource/journey-to-the-moon/
- **JPL**: elementos orbitales aproximados; semiejes **Venus 0.72333566 UA** y **Marte 1.52371034 UA**. La fila **EM Bary = 1.00000261 UA** representa el baricentro Tierra-Luna; la tabla está ajustada para 1800–2050, no son efemérides exactas. https://ssd.jpl.nasa.gov/planets/approx_pos.html
- **NASA/JPL Education**: irradiancia solar de referencia **1360.8 W/m²** en 1 UA y ley del cuadrado inverso. https://www.jpl.nasa.gov/edu/resources/lesson-plan/calculating-solar-power-in-space/

## Cálculos derivados (no datos directos descargados)

Para Venus y Marte usamos **la mitad del periodo orbital** de una elipse de transferencia idealizada, con un modelo heliocéntrico de dos cuerpos y órbitas circulares coplanares:

- semieje transferencia = (1 UA + a_destino)/2
- tiempo = 365.256 días / 2 × (semieje transferencia en UA)^(3/2)
- Venus: **~146.1 días** (modelo ideal)
- Marte: **~258.9 días** (modelo ideal)

Para una órbita media a 1 UA, la irradiancia estimada es S = 1360.8/(a/UA)^2. Así obtenemos **Venus ~2600.9 W/m²**, **Marte ~586.1 W/m²** y **Luna ~1360.8 W/m²** (aproximación de distancia solar cercana a la terrestre).

La duración lunar usada de 3 días es una **referencia histórica**, no se calcula con la fórmula heliocéntrica.

Los paneles en el constructor sí cambian de rendimiento didáctico según la irradiancia de cada destino. No se simula el cambio continuo de la distancia al Sol durante el trayecto, orientación ni degradación térmica de células fotovoltaicas. El coeficiente de conversión de irradiancia a puntos de juego es **inventado e identificado como educativo**.

## Lo que el juego NO afirma simular

- No usa las efemérides reales de una fecha específica, ni ventanas de lanzamiento.
- No resuelve N-cuerpos, delta-v de lanzamiento real, gravedad asistida, captura orbital, eclipses con geometría real, cobertura por estaciones de seguimiento o fallos por radiación medidos.
- No ofrece datos de telemetría real ni valida maniobras de vuelo. El mapa de Bézier es **ilustrativo**, no una trayectoria orbital.
- Todos los créditos, masas ficticias, fuel/power/hull/signal, puntuaciones, riesgo y consecuencias de decisiones son **unidades y reglas lúdicas**, no parámetros de un vehículo NASA.
- La prueba educativa de 4 preguntas es una herramienta de evaluación inicial; aún no hay una muestra de participantes ni resultados validados. Para demostrar impacto, reunir datos anónimos y realizar un análisis antes/después con consentimiento.

## Reproducibilidad

La lógica de decisiones se almacena en GDScript y genera resultados deterministas, usando los mismos datos y elecciones. Se incluyen pruebas en `tests/test_suite.gd` y el validador independiente `tests/validacion_matematica.py`.

Fecha de consulta de documentación: **15 de noviembre de 2026**.
