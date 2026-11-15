extends Control
const UI = preload("res://scripts/ui_kit.gd")
const DB = preload("res://scripts/mission_data.gd")
const Sim = preload("res://scripts/simulation.gd")
var event_pick: OptionButton
var option_pick: OptionButton
var compare: VBoxContainer
var original: Dictionary

func _ready() -> void:
    if GameData.flight_state.is_empty():
        get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
        return
    original = Sim.score(GameData.flight_state,GameData.config())
    _build()

func _build() -> void:
    var page: Dictionary = UI.page($Interface,"06 / EVALUACIÓN","RESULTADOS DE LA MISIÓN","Decisiones, riesgo acumulado, distancia y tiempo")
    var content: HBoxContainer = UI.row(page["body"],12,true)
    var left: VBoxContainer = UI.panel(content,1.0)
    UI.label(left,"ÍNDICE DE RENDIMIENTO",14,UI.CYAN,20)
    UI.label(left,"%d / 100" % original["overall"],35,UI.TEXT,46)
    UI.label(left,original["grade"],19,UI.GREEN if original["success"] else UI.RED if GameData.is_failed() else UI.ORANGE,26)
    UI.label(left,"RUTA: %d%%   ·   %.0f unidades" % [roundi(original["route_ratio"]*100.0),original["route_length"]],12,UI.CYAN,20)
    if GameData.is_failed():
        UI.label(left,"ANÁLISIS FORENSE: %d/30 (aprendizaje, sin telemetría)" % GameData.forensic_points,11,UI.CYAN,38)
    else:
        UI.label(left,"ANÁLISIS NASA: %d/30 pts" % original.get("evidence_score",0),11,UI.GREEN if GameData.science_done else UI.MUTED,20)
    UI.label(left,"TIEMPO TOTAL: %.1f días" % original["mission_days"],12,UI.MUTED,20)
    if GameData.is_failed():
        UI.label(left,"CAUSA: "+GameData.failure_reason(),11,UI.RED,48)
    UI.label(left,"PERFIL FINAL",12,UI.MUTED,18)
    UI.stat_bar(left,"CIENCIA",original["science"],100,UI.GREEN)
    UI.stat_bar(left,"INGENIERÍA",original["tech"],100,UI.CYAN)
    UI.stat_bar(left,"RECURSOS",original["resources"],100,UI.ORANGE)
    UI.stat_bar(left,"RIESGO CONTROLADO",original["risk"],100,UI.CYAN)
    var right: VBoxContainer = UI.panel(content,1.7)
    UI.label(right,"MISSION REWIND",20,UI.CYAN,28)
    UI.label(right,"Cambia una decisión registrada para comparar el impacto · equipo local de %d jugador(es)." % GameData.crew_size,12,UI.MUTED,28)
    UI.label(right,"EVENTO",11,UI.MUTED,17)
    event_pick = UI.dropdown(right)
    var played: int = GameData.decisions.size()
    for i in range(played):
        event_pick.add_item("%02d · %s" % [i+1,DB.EVENTS[i]["title"]])
    UI.label(right,"ALTERNATIVA",11,UI.MUTED,17)
    option_pick = UI.dropdown(right)
    compare=UI.column(right,7,true)
    event_pick.item_selected.connect(_event_changed)
    option_pick.item_selected.connect(func(_i: int): _refresh())
    if played > 0:
        var selection: int = mini(played-1,3)
        event_pick.select(selection)
        _event_changed(selection)
    else:
        UI.label(compare,"No se registraron decisiones para comparar.",12,UI.MUTED)
    UI.label(left,"DATOS NASA (CÁLCULO): %d/15" % GameData.dataset_points,12,UI.CYAN,23)
    var footer: HBoxContainer = page["footer"]
    UI.button(footer,"← NUEVA MISIÓN",false,170).pressed.connect(func():get_tree().change_scene_to_file("res://scenes/mission_select.tscn"))
    UI.button(footer,"REDISEÑAR",false,130).pressed.connect(func():get_tree().change_scene_to_file("res://scenes/engineering.tscn"))
    if GameData.completed and not GameData.science_done:
        var action_label: String = "ANÁLISIS FORENSE →" if GameData.is_failed() else "ANALIZAR NASA →"
        UI.button(footer,action_label,true,180).pressed.connect(func():get_tree().change_scene_to_file("res://scenes/science_analysis.tscn"))
    if GameData.completed and GameData.science_done and not GameData.dataset_done:
        UI.button(footer,"CALCULAR DATOS NASA →",true,210).pressed.connect(func():get_tree().change_scene_to_file("res://scenes/numeric_lab.tscn"))
    UI.spacer(footer)
    UI.button(footer,"INFORME CIENTÍFICO  →",true,240).pressed.connect(func():get_tree().change_scene_to_file("res://scenes/debrief.tscn"))
    UI.button(footer,"PRUEBA FINAL",false,150).pressed.connect(_go_post_quiz)
    UI.button(footer,"MENÚ",false,95).pressed.connect(func():get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))

func _go_post_quiz() -> void:
    GameData.quiz_mode = "after"
    get_tree().change_scene_to_file("res://scenes/knowledge_lab.tscn")

func _event_changed(idx: int) -> void:
    option_pick.clear()
    if idx < 0 or idx >= GameData.decisions.size():
        return
    for choice in DB.EVENTS[idx]["options"]:
        option_pick.add_item(str(choice["title"]))
    option_pick.select((int(GameData.decisions[idx])+1)%3)
    _refresh()

func _refresh() -> void:
    UI.clear(compare)
    var idx: int = event_pick.selected
    var alt: int = option_pick.selected
    if idx < 0 or alt < 0:
        return
    var next: Dictionary = GameData.replay_with_change(idx,alt)
    var new_score: Dictionary = Sim.score(next,GameData.config())
    var r: HBoxContainer = UI.row(compare,10)
    var a: VBoxContainer = UI.panel(r,1.0)
    UI.label(a,"ORIGINAL",12,UI.MUTED,18)
    UI.label(a,"%d PUNTOS" % original["overall"],23,UI.TEXT,29)
    UI.label(a,"Ruta %.0f   ·   %.1f días" % [original["route_length"],original["mission_days"]],11,UI.CYAN,22)
    var b: VBoxContainer = UI.panel(r,1.0)
    UI.label(b,"ALTERNATIVA",12,UI.CYAN,18)
    UI.label(b,"%d PUNTOS" % new_score["overall"],23,UI.GREEN if new_score["overall"]>=original["overall"] else UI.ORANGE,29)
    UI.label(b,"Ruta %.0f   ·   %.1f días" % [new_score["route_length"],new_score["mission_days"]],11,UI.CYAN,22)
    UI.label(compare,"DIFERENCIA: %+d puntos" % (new_score["overall"]-original["overall"]),12,UI.CYAN,18)
    UI.label(compare,"Riesgo: %d%% → %d%%" % [original["risk_percent"],new_score["risk_percent"]],12,UI.ORANGE,18)
    UI.label(compare,"Resultado alternativo: " + str(new_score["grade"]),12,UI.GREEN if new_score["success"] else UI.RED if Sim.is_failure(next) else UI.ORANGE,28)
    if Sim.is_failure(next):
        UI.label(compare,"Advertencia: "+Sim.failure_reason(next),11,UI.RED,36)
