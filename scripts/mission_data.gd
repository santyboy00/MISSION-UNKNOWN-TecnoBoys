# MISSION: UNKNOWN — datos editables del videojuego.
# Todos los valores de créditos, masa, potencia y ciencia son unidades DIDÁCTICAS.
extends RefCounted

const MISSIONS = [
    {"id": "moon", "name": "MISIÓN A LA LUNA", "code": "SELENE-01", "target": "LUNA", "difficulty": "INICIAL", "description": "Cartografía orbital de cráteres y regiones polares de la Luna.", "objective": "Cartografiar cráteres y evaluar evidencias científicas de hidrógeno e hielo polar desde órbita.", "budget": 175, "transfer": 38, "comm": 45, "science_min": 28, "days": 12, "image": "res://assets/planets/moon.png", "color": Color("#D7DEE9"), "thermal_penalty": 1.0, "signal_penalty": 1.0},
    {"id": "venus", "name": "MISIÓN A VENUS", "code": "AURELIA-02", "target": "VENUS", "difficulty": "INTERMEDIA", "description": "Estudia las nubes y la atmósfera de Venus desde una sonda orbital.", "objective": "Analizar la cubierta nubosa y obtener medidas espectrales de Venus desde órbita.", "budget": 235, "transfer": 69, "comm": 60, "science_min": 56, "days": 165, "image": "res://assets/planets/venus.png", "color": Color("#EBD09B"), "thermal_penalty": 1.30, "signal_penalty": 1.0},
    {"id": "mars", "name": "MISIÓN A MARTE", "code": "RED HORIZON-03", "target": "MARTE", "difficulty": "AVANZADA", "description": "Explora indicios de agua antigua y composición mineral de Marte.", "objective": "Obtener imágenes y medidas espectrales de Marte desde su órbita.", "budget": 295, "transfer": 142, "comm": 80, "science_min": 64, "days": 260, "image": "res://assets/planets/mars.png", "color": Color("#FFAB85"), "thermal_penalty": 1.0, "signal_penalty": 1.18}
]

const ROCKETS = [
    {"name": "KESTREL-L", "caption": "LANZADOR LIGERO", "mass_limit": 110, "fuel": 96, "cost": 42},
    {"name": "ATLAS-M", "caption": "LANZADOR MEDIO", "mass_limit": 170, "fuel": 144, "cost": 70},
    {"name": "TITAN-H", "caption": "LANZADOR PESADO", "mass_limit": 235, "fuel": 214, "cost": 110}
]

const ORBITS = [
    {"name": "ÓRBITA BAJA", "fuel": 8, "science_mult": 1.0, "description": "Menor gasto de combustible y buen enlace."},
    {"name": "ÓRBITA POLAR", "fuel": 14, "science_mult": 1.16, "description": "Mejor cobertura científica; mayor maniobra."},
    {"name": "ÓRBITA ALTA", "fuel": 22, "science_mult": 0.90, "description": "Amplia perspectiva, menores detalles medidos."}
]

const COMPONENTS = [
    {"id": "solar", "name": "PANELES SOLARES", "description": "Generan energía durante la misión.", "cost": 20, "mass": 18, "generation": 55, "consumption": 0, "comm": 0, "science": 0},
    {"id": "battery", "name": "BATERÍA EXTRA", "description": "Aumenta la capacidad energética.", "cost": 14, "mass": 15, "generation": 24, "consumption": 0, "comm": 0, "science": 0},
    {"id": "camera", "name": "CÁMARA CIENTÍFICA", "description": "Imágenes de alta resolución.", "cost": 20, "mass": 11, "generation": 0, "consumption": 16, "comm": 0, "science": 28},
    {"id": "spectro", "name": "ESPECTRÓMETRO", "description": "Detecta indicios de composición mineral.", "cost": 33, "mass": 20, "generation": 0, "consumption": 20, "comm": 0, "science": 44},
    {"id": "antenna", "name": "ANTENA DE ALTA GANANCIA", "description": "Mejora la comunicación con la Tierra.", "cost": 22, "mass": 14, "generation": 0, "consumption": 12, "comm": 70, "science": 0},
    {"id": "shield", "name": "BLINDAJE REFORZADO", "description": "Disminuye daños por partículas.", "cost": 20, "mass": 24, "generation": 0, "consumption": 0, "comm": 0, "science": 0},
    {"id": "thruster", "name": "MICROPROPULSORES", "description": "Apoyan correcciones de orientación.", "cost": 17, "mass": 12, "generation": 0, "consumption": 5, "comm": 0, "science": 0},
    {"id": "radar", "name": "RADAR CIENTÍFICO", "description": "Mapeo de superficie y subsuelo; referencia: Magellan/SHARAD.", "cost": 24, "mass": 15, "generation": 0, "consumption": 14, "comm": 0, "science": 29},
    {"id": "neutron", "name": "DETECTOR DE NEUTRONES", "description": "Permite estudiar hidrógeno lunar; referencia: LRO/LEND.", "cost": 20, "mass": 13, "generation": 0, "consumption": 9, "comm": 0, "science": 23},
    {"id": "storage", "name": "MEMORIA CIENTÍFICA", "description": "Conserva observaciones de la misión.", "cost": 15, "mass": 10, "generation": 0, "consumption": 5, "comm": 0, "science": 12}
]

# route: progreso/detour en unidades abstractas. Positivo = avanza más rápido, negativo = se desvía.
const EVENTS = [
    {"title": "CORRECCIÓN DE TRAYECTORIA", "day": 0.12, "tag": "NAVEGACIÓN", "visual": "thrusters", "story": "Los sensores detectan una desviación combinada con ruido en los giróscopos. Debes decidir entre precisión, recursos y velocidad de viaje.", "fact": "Las maniobras orbitales consumen un presupuesto finito de cambio de velocidad (delta-v).", "options": [
        {"title": "Corrección precisa + recalibración", "desc": "Mantienes la ruta óptima, pero gastas combustible y energía ahora para ahorrar tiempo después.", "effects": {"fuel": -12, "power": -8, "science": 4, "days": -2, "route": 18}},
        {"title": "Ajuste conservador", "desc": "Ahorras parte del combustible, pero aceptas una ruta menos directa y una ventana científica ligeramente peor.", "effects": {"fuel": -6, "power": -3, "hull": -8, "science": 1, "days": 3, "route": 6}},
        {"title": "Postergar la maniobra", "desc": "Conservas recursos inmediatos, pero el error orbital crece y obliga a un rodeo más largo más adelante.", "effects": {"fuel": -2, "power": -2, "hull": -15, "science": -3, "days": 7, "route": -10}}
    ]},
    {"title": "ECLIPSE EN EL TRAYECTO", "day": 0.28, "tag": "ENERGÍA", "visual": "eclipse", "story": "La nave entra en sombra profunda. Los paneles dejan de generar y debes repartir la batería entre navegación, calefacción e instrumentos.", "fact": "Los sistemas de potencia equilibran generación, almacenamiento y consumo eléctrico.", "options": [
        {"title": "Modo de supervivencia", "desc": "Proteges la nave y estabilizas la energía, pero pierdes observación y alargas la ruta por baja capacidad de maniobra.", "effects": {"power": 18, "science": -10, "signal": -4, "days": 4, "route": -5}},
        {"title": "Distribución equilibrada", "desc": "Mantienes activos sistemas clave con un costo moderado y conservas el cronograma.", "effects": {"power": -8, "science": 5, "signal": -2, "days": 1, "route": 8}},
        {"title": "Priorizar ciencia", "desc": "Sostienes los instrumentos y tomas datos valiosos, pero fuerzas batería y control térmico.", "effects": {"power": -28, "science": 14, "hull": -8, "days": 2, "route": 10}}
    ]},
    {"title": "PÉRDIDA PARCIAL DE SEÑAL", "day": 0.44, "tag": "COMUNICACIONES", "visual": "signal", "story": "El enlace con la estación terrestre se vuelve intermitente justo cuando necesitas actualizar efemérides y descargar telemetría crítica.", "fact": "Un enlace de radio depende de potencia, orientación, distancia y sensibilidad de recepción.", "options": [
        {"title": "Reorientar y reacquirir enlace", "desc": "Usas maniobra fina y energía adicional para reconstruir el enlace y evitar desviaciones futuras.", "effects": {"fuel": -8, "power": -10, "signal": 22, "days": -1, "route": 16}},
        {"title": "Elevar potencia de transmisión", "desc": "Recuperas parte de la señal sin cambiar el rumbo, aunque castigas el sistema eléctrico.", "effects": {"power": -20, "signal": 14, "hull": -3, "route": 8}},
        {"title": "Guardar datos y seguir casi a ciegas", "desc": "Proteges algo de energía y datos, pero avanzas con navegación degradada y más incertidumbre.", "effects": {"signal": -14, "science": 7, "hull": -10, "days": 5, "route": -8}}
    ]},
    {"title": "FALLO DE CONTROL TÉRMICO", "day": 0.58, "tag": "TÉRMICO", "visual": "thermal", "story": "Un radiador no disipa suficiente calor. Si eliges mal, el sobrecalentamiento puede dañar instrumentos o forzar un largo desvío de actitud.", "fact": "El control térmico protege instrumentos y electrónica de temperaturas extremas.", "options": [
        {"title": "Reducir actividad científica", "desc": "Estabilizas la temperatura y proteges la nave, pero pierdes observaciones y velocidad de trabajo.", "effects": {"power": 12, "science": -8, "days": 3, "route": 5}},
        {"title": "Reorientar la nave al balance térmico", "desc": "Gastas combustible, pero recuperas control térmico y mantienes una ruta aceptable.", "effects": {"fuel": -10, "power": -4, "hull": -4, "days": 1, "route": 12}},
        {"title": "Continuar operaciones al límite", "desc": "Obtienes más ciencia ahora, pero cualquier sobrecarga golpea casco, energía y confiabilidad.", "effects": {"science": 18, "hull": -24, "power": -16, "signal": -4, "days": 3, "route": 4}}
    ]},
    {"title": "LLUVIA DE MICROMETEORITOS", "day": 0.74, "tag": "RIESGO", "visual": "meteors", "story": "Un enjambre de partículas cruza tu corredor de vuelo. Puedes refugiarte, esquivarlo o arriesgarte para no perder tiempo.", "fact": "La protección, redundancia y planificación de riesgos mejoran la confiabilidad de una misión.", "options": [
        {"title": "Activar modo protegido", "desc": "Disminuyes la exposición y mantienes la misión viva, aunque con ligera pérdida de tiempo y energía.", "effects": {"power": -12, "signal": -3, "days": 2, "route": 7}, "special": "shield"},
        {"title": "Maniobra evasiva rápida", "desc": "Recortas riesgo con gasto fuerte de combustible, pero sigues avanzando casi sin retraso.", "effects": {"fuel": -20, "hull": -7, "power": -5, "route": 14}},
        {"title": "Mantener rumbo", "desc": "Ahorra recursos inmediatos, pero si el impacto empeora la misión puede quedar al borde del fracaso.", "effects": {"hull": -30, "power": -10, "signal": -8, "days": 6, "route": -14}}
    ]},
    {"title": "TORMENTA DE RADIACIÓN", "day": 0.78, "tag": "RADIACIÓN", "visual": "radiation", "story": "Una tormenta de partículas cargadas obliga a elegir entre proteger la electrónica, modificar la actitud o correr el riesgo de perder instrumentos.", "fact": "La radiación espacial obliga a considerar protección, redundancia y tiempos de exposición.", "options": [
        {"title": "Aislar electrónica y esperar", "desc": "Protege los componentes, pero apaga instrumentos y consume tiempo.", "effects": {"power": -9, "science": -7, "days": 4, "route": 5}, "special": "shield"},
        {"title": "Cambiar orientación rápidamente", "desc": "Requiere combustible y energía, pero conserva la ventana científica.", "effects": {"fuel": -11, "power": -8, "hull": -5, "days": 1, "route": 15}},
        {"title": "Continuar y aceptar exposición", "desc": "No detiene el viaje, pero la electrónica sufre daños acumulativos.", "effects": {"hull": -26, "power": -17, "signal": -9, "science": 5, "route": -7}}
    ]},
    {"title": "ERROR DEL PILOTO AUTOMÁTICO", "day": 0.84, "tag": "NAVEGACIÓN", "visual": "autopilot", "story": "Un giro inesperado desestabiliza la orientación. Sin una respuesta coordinada, la nave puede alejarse del corredor orbital previsto.", "fact": "Los sistemas GNC combinan sensores, algoritmos y actuadores para mantener una orientación controlada.", "options": [
        {"title": "Activar micropulsores de respaldo", "desc": "Corrección rápida, muy eficaz con el módulo de micropulsores instalado.", "effects": {"fuel": -9, "power": -7, "route": 13}, "special": "thruster"},
        {"title": "Reiniciar navegación y estimar actitud", "desc": "Gasta tiempo y reduce ciencia, pero evita un consumo fuerte de combustible.", "effects": {"power": -12, "science": -5, "days": 4, "route": 8}},
        {"title": "Ignorar el error hasta la próxima ventana", "desc": "Conserva recursos brevemente, pero genera una desviación peligrosa.", "effects": {"hull": -13, "signal": -12, "days": 7, "route": -17}}
    ]},
    {"title": "VENTANA DE OBSERVACIÓN", "day": 0.89, "tag": "CIENCIA", "visual": "science", "story": "La nave llega a la región objetivo. Debes elegir entre una campaña científica intensa, una observación balanceada o un enfoque conservador.", "fact": "El valor de una misión está en la calidad y cantidad de datos científicos útiles que logra transmitir.", "options": [
        {"title": "Barrido científico intenso", "desc": "Obtienes muchos datos y acortas la misión útil si todo sale bien, pero fuerzas potencia y comunicación.", "effects": {"science": 42, "power": -28, "signal": -10, "days": -2, "route": 18}},
        {"title": "Observación equilibrada", "desc": "Mantienes un rendimiento sólido con menor castigo a los sistemas.", "effects": {"science": 28, "power": -12, "signal": -2, "route": 11}},
        {"title": "Operación conservadora", "desc": "Reducir estrés mejora la seguridad, pero extiende la misión y deja escapar parte de la ventana.", "effects": {"science": 14, "power": 5, "signal": 4, "days": 4, "route": 2}}
    ]},
    {"title": "CALIBRACIÓN DE INSTRUMENTOS", "day": 0.96, "tag": "INSTRUMENTOS", "visual": "calibration", "story": "La cámara y el espectrómetro discrepan. Debes decidir si repetir las observaciones, confiar en los datos o detener la carga científica.", "fact": "Calibración y verificación son fundamentales para interpretar correctamente las mediciones científicas.", "options": [
        {"title": "Repetir mediciones y comparar", "desc": "Sube la confianza científica, pero requiere energía y una observación adicional.", "effects": {"science": 18, "power": -17, "days": 2, "route": 11}, "special": "instruments"},
        {"title": "Validar una muestra representativa", "desc": "Compromiso razonable entre verificación de datos y recursos.", "effects": {"science": 11, "power": -9, "days": 1, "route": 10}},
        {"title": "Omitir la calibración final", "desc": "No gastas tanta energía, pero disminuye la calidad de los datos entregados.", "effects": {"science": -18, "power": 4, "days": -1, "route": -6}}
    ]},
    {"title": "ENVÍO DE DATOS A LA TIERRA", "day": 1.0, "tag": "SEGMENTO TERRESTRE", "visual": "downlink", "story": "Los datos ya están listos. Debes decidir cómo transmitirlos con un enlace limitado y con recursos muy justos después del viaje.", "fact": "Una misión debe transmitir datos útiles a sus científicos; obtenerlos no es suficiente.", "options": [
        {"title": "Transmisión intensiva", "desc": "Maximizas la ciencia entregada y cierras antes la misión, pero la energía y la señal quedan muy comprometidas.", "effects": {"science": 18, "power": -25, "signal": -12, "days": -2, "route": 14}, "special": "downlink"},
        {"title": "Paquetes comprimidos", "desc": "Entregas datos con mejor robustez y menor gasto, aunque con premio científico moderado.", "effects": {"science": 10, "power": -10, "signal": -4, "route": 10}},
        {"title": "Guardar para retransmisión", "desc": "Aseguras recursos, pero terminas con menos datos útiles en el periodo de misión y prolongas la campaña.", "effects": {"science": -12, "power": 4, "signal": 8, "days": 5, "route": 0}, "special": "storage"}
    ]}
]
