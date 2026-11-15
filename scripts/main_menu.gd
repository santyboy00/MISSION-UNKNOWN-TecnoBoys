extends Control
const UI = preload("res://scripts/ui_kit.gd")

func _ready() -> void:
    var view = UI.page($Interface, "INICIO", "DIRIGE UNA MISIÓN ESPACIAL", "Diseña, simula y aprende de cada decisión")
    var body = UI.row(view["body"], 18, true)
    var intro = UI.panel(body, 1.5)
    UI.label(intro, "MISSION:", 32, UI.CYAN, 38)
    UI.label(intro, "UNKNOWN", 44, UI.TEXT, 52)
    UI.label(intro, "EVERY DECISION CHANGES THE UNIVERSE", 16, UI.ORANGE, 22)
    UI.label(intro, "Construye una nave, gestiona recursos, afronta diez eventos y compara cómo cambian tus resultados.", 15, UI.MUTED, 48)
    UI.spacer(intro, true)
    var actions = UI.row(intro)
    UI.button(actions, "INICIAR MISIÓN  →", true, 210).pressed.connect(_start)
    UI.button(actions, "CÓMO JUGAR", false, 150).pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/tutorial.tscn"))
    UI.button(actions, "DATOS NASA", false, 145).pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/nasa_sources.tscn"))
    UI.button(intro, "LABORATORIO DE DATOS NASA / JPL", false, 300).pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/data_explorer.tscn"))
    UI.button(intro, "PRUEBA EDUCATIVA ANTES DE JUGAR", false, 300).pressed.connect(_start_quiz)
    if GameData.has_save():
        UI.button(intro, "CONTINUAR PARTIDA", false, 250).pressed.connect(_resume)
    var info = UI.panel(body, 1.0)
    UI.label(info, "TU MISIÓN COMIENZA AQUÍ", 19, UI.CYAN, 26)
    UI.label(info, "01  SELECCIONA UN DESTINO", 14, UI.TEXT, 20)
    UI.label(info, "La Luna, Venus o Marte, siempre partiendo desde la Tierra.", 12, UI.MUTED, 34)
    UI.label(info, "02  CONSTRUYE TU NAVE", 14, UI.TEXT, 20)
    UI.label(info, "Balancea instrumentos, masa, presupuesto y energía.", 12, UI.MUTED, 34)
    UI.label(info, "03  TOMA DECISIONES", 14, UI.TEXT, 20)
    UI.label(info, "Tus acciones cambian el estado de la misión.", 12, UI.MUTED, 34)
    UI.label(info, "04  MISSION REWIND", 14, UI.TEXT, 20)
    UI.label(info, "Retrocede y compara una decisión alternativa.", 12, UI.MUTED, 34)
    UI.spacer(info, true)
    UI.label(info, "Simulación educativa en Godot 4 · Valores simplificados", 11, UI.ORANGE, 18)
    UI.label(view["footer"], "PROYECTO EDUCATIVO · EDICIÓN 2D · 1280 × 720", 11, UI.MUTED, 18)

func _start_quiz() -> void:
    GameData.quiz_mode = "before"
    get_tree().change_scene_to_file("res://scenes/knowledge_lab.tscn")

func _start() -> void:
    get_tree().change_scene_to_file("res://scenes/mission_select.tscn")

func _resume() -> void:
    if GameData.load_game():
        if GameData.completed:
            get_tree().change_scene_to_file("res://scenes/results.tscn" if GameData.science_done else "res://scenes/science_analysis.tscn")
        elif not GameData.launched:
            get_tree().change_scene_to_file("res://scenes/engineering.tscn")
        else:
            get_tree().change_scene_to_file("res://scenes/flight.tscn")
