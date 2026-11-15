extends Control
# Análisis NUMÉRICO con cifras publicadas: NASA NSSDC Planetary Fact Sheet.
# 3 actividades de cálculo. Tras una derrota es aprendizaje forense, NO telemetría.
const UI = preload("res://scripts/ui_kit.gd")
const Facts = preload("res://scripts/planetary_facts.gd")
var feedback: bool = false

func _ready() -> void:
    if GameData.flight_state.is_empty() or not GameData.completed or not GameData.science_done:
        get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
        return
    _render()

func _render() -> void:
    var idx: int = GameData.dataset_answers.size()
    if GameData.dataset_done and not feedback:
        get_tree().change_scene_to_file("res://scenes/results.tscn")
        return
    if idx >= 3 and not feedback:
        get_tree().change_scene_to_file("res://scenes/results.tscn")
        return
    var current: int = mini(idx,2) if not feedback else idx-1
    var t: Dictionary = Facts.task(GameData.mission_id,current)
    if t.is_empty():
        get_tree().change_scene_to_file("res://scenes/results.tscn")
        return
    var name: String = Facts.body_name(GameData.mission_id)
    var dest: Dictionary = Facts.record(GameData.mission_id)
    var earth: Dictionary = Facts.earth()
    var page: Dictionary = UI.page($Interface,"DATOS NASA · %d/3" % [current+1],"LABORATORIO CUANTITATIVO","Tabla de datos NASA NSSDC y cálculos reproducibles · %s" % name)
    var sides: HBoxContainer = UI.row(page["body"],12,true)
    var left: VBoxContainer = UI.panel(sides,1.05)
    UI.label(left,"TABLA NASA: MEDIDAS PUBLICADAS",15,UI.CYAN,24)
    UI.label(left,"PARÁMETRO                         TIERRA          %s" % name,11,UI.ORANGE,24)
    _metric_row(left,"Gravedad",earth["gravity_m_s2"],dest["gravity_m_s2"],"m/s²",12.0)
    _metric_row(left,"Escape",earth["escape_km_s"],dest["escape_km_s"],"km/s",13.0)
    _metric_row(left,"Diámetro",earth["diameter_km"],dest["diameter_km"],"km",15000.0)
    _metric_row(left,"Irradiancia",earth["irradiance_w_m2"],dest["irradiance_w_m2"],"W/m²",3000.0)
    UI.label(left,"FUENTE: NASA NSSDCA · Planetary Fact Sheet (métrico)",12,UI.CYAN,35)
    UI.label(left,"Estos son valores astronómicos publicados. Los cálculos de esta pantalla NO representan telemetría obtenida por la nave.",12,UI.MUTED,56)
    UI.spacer(left,true)
    UI.button(left,"ABRIR TABLA ORIGINAL NASA  ↗",false).pressed.connect(func():OS.shell_open(Facts.SOURCE))
    var right: VBoxContainer = UI.panel(sides,1.15)
    UI.label(right,"ACTIVIDAD %d · %s" % [current+1,t["metric"]],15,UI.CYAN,26)
    UI.label(right,t["question"],16,UI.TEXT,70)
    UI.label(right,"Calcula con los valores de la tabla. No es necesario buscar información externa.",12,UI.MUTED,38)
    if feedback:
        var picked: int = int(GameData.dataset_answers[current])
        var correct: bool = picked == int(t["right"])
        UI.label(right,"CÁLCULO CORRECTO" if correct else "CÁLCULO INCORRECTO",17,UI.GREEN if correct else UI.RED,30)
        UI.label(right,t["explanation"],13,UI.TEXT,76)
        UI.label(right,"RESULTADO: %d / 15 puntos educativos" % GameData.dataset_points,14,UI.CYAN,28)
        UI.spacer(right,true)
        UI.button(right,"TERMINAR ANÁLISIS  →" if GameData.dataset_done else "SIGUIENTE DATO  →",true).pressed.connect(_continue)
    else:
        for i in range(3):
            var b: Button = UI.button(right,"%s) %s" % [["A","B","C"][i],t["options"][i]],false)
            b.custom_minimum_size.y=46
            b.pressed.connect(_answer.bind(i))
        UI.spacer(right,true)
        UI.label(right,"Después de una derrota, el resultado solo representa aprendizaje con el archivo público NASA.",11,UI.MUTED,50)
    var footer: HBoxContainer = page["footer"]
    UI.button(footer,"← RESULTADOS",false,175).pressed.connect(func():get_tree().change_scene_to_file("res://scenes/results.tscn"))
    UI.spacer(footer)
    UI.label(footer,"%d DE 3 · DATOS DE NASA, NO CIFRAS INVENTADAS" % [current+1],12,UI.MUTED,22)

func _metric_row(parent: VBoxContainer, label_text: String, earth_value: float, dest_value: float, unit: String, scale: float) -> void:
    var line: HBoxContainer = UI.row(parent,6)
    UI.label(line,label_text,12,UI.TEXT,18,false)
    var numbers: Label = UI.label(line,"%.1f → %.1f %s" % [earth_value,dest_value,unit],12,UI.CYAN,18,false)
    numbers.size_flags_horizontal=Control.SIZE_SHRINK_END
    var bar: ProgressBar = ProgressBar.new()
    bar.min_value=0.0
    bar.max_value=scale
    bar.value=dest_value
    bar.show_percentage=false
    bar.custom_minimum_size.y=9
    bar.add_theme_stylebox_override("background",UI.bar_style(Color("#264158")))
    bar.add_theme_stylebox_override("fill",UI.bar_style(UI.CYAN))
    parent.add_child(bar)

func _answer(choice: int) -> void:
    if feedback or GameData.dataset_done:
        return
    GameData.register_dataset_choice(choice)
    feedback=true
    _render()

func _continue() -> void:
    feedback=false
    _render()
