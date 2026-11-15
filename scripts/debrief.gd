extends Control
const UI = preload("res://scripts/ui_kit.gd")
const DB = preload("res://scripts/mission_data.gd")
const Sim = preload("res://scripts/simulation.gd")
const NASA = preload("res://scripts/nasa_data.gd")
const Evidence = preload("res://scripts/science_evidence.gd")
var status: Label

func _ready() -> void:
    if GameData.flight_state.is_empty():
        get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
        return
    var state: Dictionary = GameData.flight_state
    var m: Dictionary = DB.MISSIONS[GameData.mission_id]
    var result: Dictionary = Sim.score(state,GameData.config())
    var page: Dictionary = UI.page($Interface,"07 / INFORME","BITÁCORA DE LA MISIÓN",GameData.team_name+" · "+m["code"])
    var sides: HBoxContainer = UI.row(page["body"],12,true)
    var left: VBoxContainer = UI.panel(sides,1.6)
    UI.label(left,"DECISIONES Y DURACIÓN DE LA MISIÓN",14,UI.CYAN,21)
    # Una única barra de página; la lista completa permanece alcanzable con rueda/teclado.
    var items: VBoxContainer = UI.column(left,7)
    for i in range(state["log"].size()):
        var item: Dictionary = state["log"][i]
        var card: VBoxContainer = UI.panel(items,1.0)
        card.size_flags_vertical=Control.SIZE_SHRINK_BEGIN
        UI.label(card,"%02d · %s" % [i+1,item["event"]],12,UI.ORANGE,20)
        UI.label(card,"Elegiste: "+str(item["decision"]),11,UI.TEXT,20)
        UI.label(card,"Día %.1f · Avance %.0f%%" % [item["day"],item["route_after"]*100.0],11,UI.MUTED,17)
    var right: VBoxContainer = UI.panel(sides,1.0)
    UI.label(right,"RESULTADO DEL EQUIPO",14,UI.CYAN,20)
    UI.label(right,"%d / 100" % result["overall"],31,UI.TEXT,42)
    UI.label(right,result["grade"],16,UI.GREEN if result["success"] else UI.RED if GameData.is_failed() else UI.ORANGE,24)
    UI.label(right,"Viaje: %.1f días · Ruta: %.0f unidades" % [result["mission_days"],result["route_length"]],12,UI.CYAN,34)
    UI.label(right,"Ciencia: %.0f · Energía: %.0f · Combustible: %.0f" % [state["science"],state["power"],state["fuel"]],12,UI.MUTED,36)
    UI.label(right,"RIESGO FINAL: %d%%" % result["risk_percent"],12,UI.ORANGE,20)
    if GameData.is_failed():
        UI.label(right,"ANÁLISIS FORENSE: %d/30 aciertos ponderados; 0 datos de misión recuperados" % GameData.forensic_points,11,UI.CYAN,45)
    else:
        UI.label(right,"EVIDENCIAS NASA: %d/30 pts (%d/3 aciertos)" % [GameData.science_points,GameData.science_correct],11,UI.CYAN,28)
    UI.label(right,"REFERENCIA NASA: %.0f días ideales, %.0f W/m²" % [NASA.ideal_transfer_days(GameData.mission_id),NASA.solar_flux_wm2(GameData.mission_id)],11,UI.CYAN,34)
    if GameData.is_failed():
        UI.label(right,"Fracaso: "+GameData.failure_reason(),11,UI.RED,56)
    if GameData.quiz_before >= 0:
        var summary: String = "Aprendizaje: antes %d/4" % GameData.quiz_before
        if GameData.quiz_after >= 0:
            summary += " · después %d/4" % GameData.quiz_after
        UI.label(right,summary,11,UI.CYAN,22)
    UI.label(right,"ANÁLISIS DE TABLA NASA: %d/15 · %d/3 aciertos" % [GameData.dataset_points,GameData.dataset_correct],12,UI.CYAN,24)
    UI.label(right,"Δv maniobras: %.0f m/s gastados · %.0f m/s disponibles (hipótesis)" % [state.get("delta_v_used_mps",0.0),state.get("onboard_delta_v_mps",0.0)],12,UI.MUTED,48)
    UI.label(right,"LECCIÓN DE INGENIERÍA",14,UI.ORANGE,21)
    UI.label(right,"Las decisiones más rápidas suelen consumir combustible o energía. Las seguras pueden prolongar el trayecto. Debes equilibrar los subsistemas.",12,UI.MUTED,66)
    UI.button(right,"EXPORTAR EVALUACIÓN ANÓNIMA .CSV",false).pressed.connect(_export_learning_csv)
    UI.spacer(right,true)
    UI.label(right,"Modelo educativo normalizado, no simulación de vuelo certificada.",11,UI.MUTED,30)
    var footer: HBoxContainer = page["footer"]
    UI.button(footer,"← RESULTADOS",false,170).pressed.connect(func():get_tree().change_scene_to_file("res://scenes/results.tscn"))
    UI.spacer(footer)
    status=UI.label(footer,"",11,UI.GREEN,18)
    UI.button(footer,"LAB. NASA",false,130).pressed.connect(func():get_tree().change_scene_to_file("res://scenes/data_explorer.tscn"))
    UI.button(footer,"EXPORTAR .TXT",true,180).pressed.connect(_export)

func _export() -> void:
    var s: Dictionary = GameData.flight_state
    var result: Dictionary = Sim.score(s,GameData.config())
    var m: Dictionary = DB.MISSIONS[GameData.mission_id]
    var lines: Array[String] = ["MISSION: UNKNOWN | INFORME", "Equipo: "+GameData.team_name, "Misión: "+m["code"],"Objetivo: "+m["objective"],"Resultado: "+result["grade"],"Puntos: %d/100" % result["overall"],"Distancia equivalente: %.1f unidades" % result["route_length"],"Duración: %.1f días" % result["mission_days"],"Riesgo final: %d%%" % result["risk_percent"]]
    if GameData.quiz_before >= 0:
        lines.append("Respuestas correctas antes: %d/4" % GameData.quiz_before)
    if GameData.quiz_after >= 0:
        lines.append("Respuestas correctas después: %d/4" % GameData.quiz_after)
    if GameData.is_failed():
        lines.append("CAUSA DE FRACASO: "+GameData.failure_reason())
    for i in range(s["log"].size()):
        var entry: Dictionary = s["log"][i]
        lines.append("%02d. %s | %s | Día %.1f | Ruta %.0f%%" % [i+1,entry["event"],entry["decision"],entry["day"],entry["route_after"]*100.0])
    if GameData.is_failed():
        lines.append("ANÁLISIS FORENSE PEDAGÓGICO: %d/30 (no son datos recuperados de la nave)" % GameData.forensic_points)
    else:
        lines.append("Evidencias NASA: %d/30 puntos (%d/3 respuestas correctas)" % [GameData.science_points,GameData.science_correct])
    lines.append("Capacidad de maniobra restante (hipótesis Tsiolkovski): %.1f m/s" % float(s.get("onboard_delta_v_mps",0)))
    lines.append("Delta-v gastado (vehículo ficticio): %.1f m/s" % float(s.get("delta_v_used_mps",0)))
    lines.append("Cálculos con tabla NASA NSSDC: %d/15 puntos (%d/3 aciertos)" % [GameData.dataset_points,GameData.dataset_correct])
    lines.append("NASA Fact Sheet: https://nssdc.gsfc.nasa.gov/planetary/factsheet/")
    lines.append("Transferencia ideal: %.1f días; retrasos evitables: %.1f días" % [NASA.ideal_transfer_days(GameData.mission_id),float(s.get("delay_days",0))])
    lines.append("NASA/JPL datos: " + NASA.physics_summary(GameData.mission_id))
    var evidence: Array = Evidence.for_mission(GameData.mission_id)
    for item in evidence:
        lines.append("Evidencia %s: %s | NASA: %s" % [item["id"],item["fact"],item["source"]])
    lines.append("NASA JPL órbitas: https://ssd.jpl.nasa.gov/planets/approx_pos.html")
    lines.append("NASA/JPL energía solar: https://www.jpl.nasa.gov/edu/resources/lesson-plan/calculating-solar-power-in-space/")
    lines.append("NASA Luna: https://science.nasa.gov/moon/facts/")
    lines.append("Valores normalizados y mecánicas educativas; no navegación certificada.")
    var file: FileAccess = FileAccess.open("user://informe_mission_unknown.txt",FileAccess.WRITE)
    if file == null:
        status.text="Error al guardar"
        return
    file.store_string("\n".join(lines))
    status.text="Guardado en user://"

# Una fila sin nombre, IP, correo ni identificadores de usuario.
# El usuario decide si agregarla a su estudio; un caso NO constituye validación estadística.
func _export_learning_csv() -> void:
    var path: String="user://evaluacion_anonima_v13.csv"
    var f: FileAccess=FileAccess.open(path,FileAccess.WRITE)
    if f==null:
        status.text="No fue posible guardar el CSV"
        return
    var before: int=GameData.quiz_before
    var after: int=GameData.quiz_after
    var delta: int=after-before if before>=0 and after>=0 else 0
    f.store_csv_line(PackedStringArray(["destino","pretest_4","postest_4","diferencia","nasa_datos_15","evidencias_30","resultado"]))
    f.store_csv_line(PackedStringArray([str(GameData.mission_id),str(before),str(after),str(delta),str(GameData.dataset_points),str(GameData.science_points),"perdida" if GameData.is_failed() else "finalizada"]))
    status.text="CSV anónimo guardado en user://"
