# Procedencia verificable y límites científicos

**Dataset en el juego:** `data/nasa_planetary_facts.csv` se transcribió de la tabla pública NASA/NSSDC Planetary Fact Sheet (unidades métricas) y de las fichas individuales de irradiancia. Fecha de consulta 2026-11-15.

- Tabla principal: https://nssdc.gsfc.nasa.gov/planetary/factsheet/
- Venus: https://nssdc.gsfc.nasa.gov/planetary/factsheet/venusfact.html
- Marte: https://nssdc.gsfc.nasa.gov/planetary/factsheet/marsfact.html
- Luna: https://nssdc.gsfc.nasa.gov/planetary/factsheet/moonfact.html
- Descripción de CRISM/MRO: https://science.nasa.gov/photojournal/mineral-spectra-from-nili-fossae-mars/
- Magellan: https://science.nasa.gov/mission/magellan/

## Qué se utiliza directamente

El laboratorio numérico **lee el CSV** y calcula el peso (F=m·g), la proporción de velocidad de escape con respecto a Tierra y la proporción de irradiancia. Los valores absolutos de gravedad/escape/diámetro proceden de la tabla NASA; los valores de irradiancia están redondeados conforme a las fichas detalladas NASA.

Las relaciones numéricas del laboratorio son reproducibles sin conexión. Los datos no proceden de una medición en vivo ni de productos científicos PDS de resolución espacial. **La velocidad de escape desde superficie NO es el Δv de una transferencia interplanetaria.**

## Física de maniobras

El motor usa una **hipótesis de vehículo ficticio** con masa de diseño y 2 kg de propelente por unidad de combustible, e Isp hipotético de 320 s. Tsiolkovski calcula el Δv restante conforme se consume ese propelente. La eficiencia de ruta es una regla didáctica con contribución del gasto de Δv, no integración gravitacional de una órbita. Los tiempos interplanetarios son transferencias Hohmann idealizadas; no modelan fechas de lanzamiento ni captura.

## Datos y ética

La evaluación pre/post se exporta bajo consentimiento del jugador como CSV individual anónimo; no guarda identificadores. Sin pruebas con personas no puede proclamarse impacto educativo demostrado. En derrota, la actividad de datos NASA mide comprensión, **no telemetría recuperada de una nave destruida**.
