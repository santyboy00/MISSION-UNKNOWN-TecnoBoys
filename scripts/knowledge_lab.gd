extends Control
# Pruebas paralelas A y B. No se revelan respuestas durante la medición inicial.
# No identifica usuarios ni afirma validar el impacto por sí sola.
const UI = preload("res://scripts/ui_kit.gd")
const BEFORE = [
 {"q":"Si una sonda pasa de 1 UA a 2 UA del Sol, la irradiancia solar...", "a":["Aumenta 4 veces","Se reduce a una cuarta parte","Permanece igual"],"right":1,"why":"La irradiancia es inversamente proporcional al cuadrado de la distancia."},
 {"q":"Al planear una transferencia interplanetaria, ¿qué parámetro orbital es fundamental?", "a":["Semiejes mayores orbitales","Color de la superficie","Diámetro de antena terrestre"],"right":0,"why":"En un Hohmann ideal el semieje mayor de la transferencia determina el período."},
 {"q":"Agregar un espectrómetro a una nave generalmente...", "a":["Aumenta datos y también masa/potencia","Reduce siempre el combustible a cero","No cambia los recursos"],"right":0,"why":"La carga científica ocupa masa, energía y capacidad de datos."},
 {"q":"¿Qué componente de una misión entrega observaciones a investigadores?", "a":["Sólo el cohete","Segmento terrestre y de usuarios","Sólo el motor"],"right":1,"why":"Sin comunicación y análisis los datos no cumplen el objetivo de ciencia."}
]
const AFTER = [
 {"q":"Una nave se acerca al Sol de 2 UA a 1 UA. En un modelo ideal, la irradiancia...", "a":["Se divide entre cuatro","Se multiplica por cuatro","No cambia"],"right":1,"why":"La razón de irradiancia es (2/1)² = 4."},
 {"q":"Para estimar un traslado Hohmann ideal Tierra-Marte se necesita...", "a":["El color del planeta","Sólo el radio de la nave","El semieje mayor de las dos órbitas"],"right":2,"why":"Las órbitas se aproximan como circulares y se usa el semieje de transferencia."},
 {"q":"Si equipas un radar para mapear Venus, el mayor compromiso probable es...", "a":["Mayor costo, masa y consumo","Menor tamaño sin energía","Comunicación infinita"],"right":0,"why":"La instrumentación mejora ciencia, pero impone requisitos."},
 {"q":"Si los instrumentos capturan datos pero no se pueden transmitir...", "a":["La misión científica ya está garantizada","Los datos siguen necesitando descarga/análisis","El lanzador puede retransmitirlos siempre"],"right":1,"why":"El segmento terrestre debe recibir los datos y el usuario debe interpretarlos."}
]
var index: int = 0
var hits: int = 0
var phase: String = "before"
var selected: int = -1
func _ready() -> void:
    phase = GameData.quiz_mode
    _render()
func _render() -> void:
    var questions: Array = AFTER if phase == "after" else BEFORE
    var done: bool = index >= questions.size()
    var page: Dictionary = UI.page($Interface,"MEDICIÓN EDUCATIVA", "PRUEBA DE CONOCIMIENTO", "Formularios paralelos, resultados individuales locales; no constituyen por sí solos un estudio de impacto")
    var columns: HBoxContainer = UI.row(page["body"],12,true)
    var left: VBoxContainer = UI.panel(columns,1.65)
    var right: VBoxContainer = UI.panel(columns,1.0)
    UI.label(left,"POSTEST: FORMULARIO B" if phase == "after" else "PRETEST: FORMULARIO A",14,UI.CYAN,24)
    if done:
        GameData.set_quiz_result(phase,hits)
        UI.label(left,"RESULTADO: %d / 4" % hits,30,UI.TEXT,45)
        if GameData.quiz_before >= 0 and GameData.quiz_after >= 0:
            UI.label(left,"CAMBIO INDIVIDUAL: %+d aciertos" % [GameData.quiz_after-GameData.quiz_before],17,UI.GREEN if GameData.quiz_after >= GameData.quiz_before else UI.ORANGE,28)
        UI.label(left,"Resultado individual de práctica, no evidencia estadística de impacto. Para demostrar aprendizaje: reunir participantes voluntarios, aplicar formularios equivalentes y documentar metodología.",13,UI.MUTED,80)
        UI.spacer(left,true)
        UI.button(left,"VOLVER AL JUEGO",true).pressed.connect(_exit)
    else:
        var q: Dictionary = questions[index]
        UI.label(left,"PREGUNTA %d DE %d" % [index+1,questions.size()],12,UI.ORANGE,22)
        UI.label(left,str(q["q"]),17,UI.TEXT,70)
        for i in range(3):
            var b: Button = UI.button(left,"%s) %s" % [["A","B","C"][i],str(q["a"][i])],false)
            b.custom_minimum_size.y = 52
            b.disabled = selected >= 0
            b.pressed.connect(_answer.bind(i))
        if selected >= 0:
            if phase == "after":
                UI.label(left,"RESPUESTA CORRECTA" if selected == int(q["right"]) else "RESPUESTA INCORRECTA",14,UI.GREEN if selected == int(q["right"]) else UI.ORANGE,22)
                UI.label(left,str(q["why"]),12,UI.MUTED,55)
            else:
                UI.label(left,"Respuesta registrada. La corrección se reserva para no contaminar la evaluación inicial.",12,UI.CYAN,54)
            UI.spacer(left,true)
            UI.button(left,"SIGUIENTE  →",true).pressed.connect(_next)
    UI.label(right,"MÉTODO",17,UI.CYAN,26)
    UI.label(right,"Se usan dos versiones de cuatro preguntas sobre los mismos conceptos, evitando revelar las soluciones del pretest.",13,UI.TEXT,100)
    UI.label(right,"ÁREAS MEDIDAS",13,UI.ORANGE,20)
    UI.label(right,"Energía solar, mecánica orbital idealizada, selección de instrumentos y transmisión científica.",13,UI.MUTED,85)
    UI.spacer(right,true)
    UI.label(right,"La aplicación guarda el resultado localmente, sin enviar datos personales.",12,UI.CYAN,52)
    UI.button(page["footer"],"← VOLVER",false,150).pressed.connect(_exit)
func _answer(i: int) -> void:
    if selected >= 0:
        return
    selected = i
    var current_questions: Array = AFTER if phase == "after" else BEFORE
    var q: Dictionary = current_questions[index]
    if i == int(q["right"]):
        hits += 1
    _render()
func _next() -> void:
    index += 1
    selected = -1
    _render()
func _exit() -> void:
    get_tree().change_scene_to_file("res://scenes/results.tscn" if GameData.completed and not GameData.flight_state.is_empty() else "res://scenes/main_menu.tscn")
