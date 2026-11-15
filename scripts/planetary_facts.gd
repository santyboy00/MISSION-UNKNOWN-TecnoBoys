extends RefCounted
# Cifras del cuadro resumen de NASA NSSDC; no es telemetría de la partida.
const CSV_PATH = "res://data/nasa_planetary_facts.csv"
const SOURCE = "https://nssdc.gsfc.nasa.gov/planetary/factsheet/"
const COLUMNS: Array[String] = ["gravity_m_s2", "escape_km_s", "diameter_km", "mean_temp_c", "pressure_bars", "irradiance_w_m2"]

static func read_all() -> Dictionary:
    var output: Dictionary = {}
    var f: FileAccess = FileAccess.open(CSV_PATH, FileAccess.READ)
    if f == null:
        push_error("NASA CSV no disponible: " + CSV_PATH)
        return output
    var header: PackedStringArray = f.get_csv_line()
    while not f.eof_reached():
        var parts: PackedStringArray = f.get_csv_line()
        if parts.size() != header.size():
            continue
        var body: String = str(parts[0])
        if body.is_empty():
            continue
        var row: Dictionary = {}
        for k in range(1,header.size()):
            row[str(header[k])] = float(parts[k])
        output[body] = row
    return output

static func body_name(mission_id: int) -> String:
    return ["LUNA", "VENUS", "MARTE"][clampi(mission_id,0,2)]

static func record(mission_id: int) -> Dictionary:
    return read_all().get(body_name(mission_id), {})

static func earth() -> Dictionary:
    return read_all().get("TIERRA", {})

# Tres OPERACIONES reproducibles con valores NASA. No se piden datos inventados.
static func task(mission_id: int, index: int) -> Dictionary:
    var r: Dictionary = record(mission_id)
    var e: Dictionary = earth()
    if r.is_empty() or e.is_empty():
        return {}
    var correct: float = 0.0
    var question: String = ""
    var explanation: String = ""
    var metric: String = ""
    var unit: String = ""
    match index:
        0:
            metric = "GRAVEDAD SUPERFICIAL"
            unit = "N"
            question = "Una herramienta de 10 kg está en la superficie de %s. ¿Qué peso aproximado tendría?" % body_name(mission_id)
            correct = 10.0 * float(r["gravity_m_s2"])
            explanation = "Peso = masa × gravedad = 10 kg × %.1f m/s² = %.1f N. La masa permanece en 10 kg." % [r["gravity_m_s2"],correct]
        1:
            metric = "VELOCIDAD DE ESCAPE"
            unit = "%"
            question = "¿La velocidad de escape de %s equivale aproximadamente a qué porcentaje de la terrestre?" % body_name(mission_id)
            correct = roundf(float(r["escape_km_s"])/float(e["escape_km_s"])*100.0)
            explanation = "%.1f / %.1f × 100 = %.0f%%. La velocidad de escape superficial NO equivale al Δv de esta misión." % [r["escape_km_s"],e["escape_km_s"],correct]
        _:
            metric = "IRRADIANCIA SOLAR"
            unit = "%"
            question = "¿Qué porcentaje de la irradiancia de referencia terrestre recibe %s?" % body_name(mission_id)
            correct = roundf(float(r["irradiance_w_m2"])/float(e["irradiance_w_m2"])*100.0)
            explanation = "%.1f / %.1f × 100 = %.0f%%; suponemos distancia media y superficie colectora idealizada." % [r["irradiance_w_m2"],e["irradiance_w_m2"],correct]
    var options: Array[String] = ["", "", ""]
    var right: int = (mission_id + index + 1) % 3
    var wrong_a: float = maxf(1.0,roundf(correct * 0.55))
    var wrong_b: float = roundf(correct * 1.65 + 1.0)
    options[right] = "%.0f %s" % [correct, unit]
    options[(right+1)%3] = "%.0f %s" % [wrong_a, unit]
    options[(right+2)%3] = "%.0f %s" % [wrong_b, unit]
    return {"metric":metric,"question":question,"options":options,"right":right,"explanation":explanation,"correct_value":correct}

static func score(choice: int, mission_id: int, index: int) -> int:
    return 5 if choice == int(task(mission_id,index).get("right",-1)) else 0
