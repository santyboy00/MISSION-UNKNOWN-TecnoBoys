extends Control
# Etapa de interpretación: hallazgos NASA resumidos, no datos crudos.
const UI = preload("res://scripts/ui_kit.gd")
const DB = preload("res://scripts/mission_data.gd")
const Evidence = preload("res://scripts/science_evidence.gd")
const Ground = preload("res://scripts/ground_network.gd")
var feedback_index: int = -1

func _ready() -> void:
    if GameData.flight_state.is_empty() or not GameData.completed:
        get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
        return
    _render()

func _render() -> void:
    var items: Array = Evidence.for_mission(GameData.mission_id)
    var idx: int = GameData.science_answers.size()
    if GameData.science_done and feedback_index < 0:
        get_tree().change_scene_to_file("res://scenes/results.tscn" if GameData.dataset_done else "res://scenes/numeric_lab.tscn")
        return
    var show_index: int = feedback_index if feedback_index >= 0 else idx
    if show_index >= items.size():
        get_tree().change_scene_to_file("res://scenes/results.tscn" if GameData.dataset_done else "res://scenes/numeric_lab.tscn")
        return
    var item: Dictionary = items[show_index]
    var forensic: bool = GameData.is_failed()
    var heading: String = "ANÁLISIS FORENSE NASA" if forensic else "ANÁLISIS DE EVIDENCIA NASA"
    var sub: String = "La misión falló. Analiza FUENTES PÚBLICAS NASA: no se recuperó telemetría de la nave." if forensic else "Interpreta hallazgos publicados por NASA y vincúlalos con tu diseño."
    var page: Dictionary = UI.page($Interface,"SEGMENTO DE CIENCIA · %d/3" % [show_index+1],heading,sub)
    var parts: HBoxContainer = UI.row(page["body"],12,true)
    var observations: VBoxContainer = UI.panel(parts,1.0)
    UI.label(observations,"MISIÓN REAL: " + str(item["mission"]),14,UI.CYAN,25)
    UI.label(observations,str(item["metric"]),17,UI.ORANGE,34)
    UI.label(observations,str(item["fact"]),13,UI.TEXT,115)
    if forensic:
        UI.label(observations,"ESTADO: SIN TELEMETRÍA DE LA NAVE",11,UI.RED,24)
        UI.label(observations,"Usamos publicaciones de NASA para investigar la causa y el diseño; no simulamos una recuperación imposible.",11,UI.MUTED,55)
    else:
        UI.label(observations,"ENLACE TERRESTRE: " + str(Ground.plan(GameData.ground_id)["name"]),11,UI.CYAN,25)
        UI.label(observations,"Capacidad ficticia de descarga: %d/30 unidades" % int(Ground.plan(GameData.ground_id)["capacity"]),11,UI.MUTED,24)
    UI.label(observations,"DOCUMENTO NASA:",11,UI.MUTED,18)
    UI.label(observations,str(item["id"]),11,UI.CYAN,20)
    UI.button(observations,"CONSULTAR FUENTE ORIGINAL",false).pressed.connect(func():OS.shell_open(str(item["source"])))
    UI.spacer(observations,true)
    UI.label(observations,"Estos textos resumen resultados publicados; no son mediciones inventadas ni se presentan como datos crudos de telemetría.",11,UI.MUTED,72)
    var analysis: VBoxContainer = UI.panel(parts,1.35)
    UI.label(analysis,"INTERPRETACIÓN CIENTÍFICA",15,UI.CYAN,23)
    UI.label(analysis,str(item["question"]),16,UI.TEXT,75)
    var compatible: bool = Evidence.compatible(item,GameData.components)
    UI.label(analysis,"Instrumento necesario: %s" % str(item["instrument"]).to_upper(),12,UI.CYAN,22)
    var equipment_text: String = "EQUIPADO" if compatible else "NO EQUIPADO: máximo 3/10 puntos de MISIÓN"
    if forensic:
        equipment_text = "EXAMEN RETROSPECTIVO: 10 puntos por respuesta correcta; sin datos recuperados"
    UI.label(analysis,equipment_text,11,UI.GREEN if compatible else UI.ORANGE,40)
    if feedback_index >= 0:
        var selected: int = int(GameData.science_answers[feedback_index])
        var correct: bool = selected == int(item["answer"])
        UI.label(analysis,"RESPUESTA CORRECTA" if correct else "RESPUESTA NO SUSTENTADA",14,UI.GREEN if correct else UI.RED,25)
        UI.label(analysis,str(item["why"]),12,UI.MUTED,70)
        var total_points: int = GameData.forensic_points if forensic else GameData.science_points
        UI.label(analysis,("Aprendizaje forense: %d / 30" if forensic else "Puntuación científica: %d / 30") % total_points,13,UI.CYAN,22)
        UI.spacer(analysis,true)
        UI.button(analysis,"FINALIZAR ANÁLISIS  →" if GameData.science_done else "SIGUIENTE EVIDENCIA  →",true).pressed.connect(_next)
    else:
        for i in range(3):
            var button: Button = UI.button(analysis,"%s  %s" % [["A","B","C"][i],str(item["options"][i])],false)
            button.custom_minimum_size.y = 52
            button.add_theme_font_size_override("font_size",12)
            button.pressed.connect(_answer.bind(i))
        UI.spacer(analysis,true)
        UI.label(analysis,"No confundir comprensión educativa con observaciones reales de nuestra misión." if forensic else "Acertar sin instrumento compatible permite aprender, pero limita los datos ficticios recibidos.",11,UI.MUTED,48)
    var footer: HBoxContainer = page["footer"]
    UI.label(footer,"FUENTE: NASA SCIENCE · CONTENIDO DIDÁCTICO VERIFICABLE",11,UI.MUTED,18)
    UI.spacer(footer)
    UI.button(footer,"DATOS NASA  ↗",false,170).pressed.connect(func():OS.shell_open(str(item["source"])))

func _answer(choice: int) -> void:
    var idx: int = GameData.science_answers.size()
    var items: Array = Evidence.for_mission(GameData.mission_id)
    if idx < 0 or idx >= items.size() or feedback_index >= 0:
        return
    var record: Dictionary = items[idx]
    var correct: bool = choice == int(record["answer"])
    var points: int = Evidence.observation_score(record,choice,GameData.components)
    GameData.register_science_choice(idx,choice,points,correct)
    feedback_index = idx
    _render()

func _next() -> void:
    feedback_index = -1
    _render()
