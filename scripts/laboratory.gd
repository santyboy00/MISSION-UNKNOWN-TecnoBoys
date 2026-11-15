extends Control
const UI = preload("res://scripts/ui_kit.gd")
const Sim = preload("res://scripts/simulation.gd")
var status: Label
var launch_button: Button
var run_button: Button
var verification: Dictionary

func _ready() -> void:
    var page = UI.page($Interface,"03 / VERIFICACIÓN", "LABORATORIO DE INGENIERÍA", "Todos los sistemas deben aprobar antes del lanzamiento")
    verification = Sim.evaluate(GameData.config())
    var columns = UI.row(page["body"], 14, true)
    var left = UI.panel(columns,1.65)
    UI.label(left,"PRUEBAS DE SUBSISTEMAS",16,UI.CYAN,24)
    for item in verification["checks"]:
        var r = UI.row(left,10)
        UI.label(r,"●" if item["ok"] else "✕",16,UI.GREEN if item["ok"] else UI.RED,22).size_flags_horizontal=Control.SIZE_SHRINK_BEGIN
        var details = UI.column(r,2)
        UI.label(details,item["name"],13,UI.TEXT,20)
        UI.label(details,item["detail"],11,UI.MUTED,30)
    var right = UI.panel(columns,1.0)
    UI.label(right,"ESTADO DE VERIFICACIÓN",16,UI.CYAN,24)
    UI.label(right,"APROBABLE" if verification["valid"] else "FALTA CORREGIR",23,UI.GREEN if verification["valid"] else UI.RED,32)
    UI.label(right,"El diagnóstico verifica presupuesto, masa, electricidad, comunicaciones, combustible e instrumentos.",13,UI.MUTED,54)
    UI.label(right,"Valores educativos; no certifica un vuelo real.",12,UI.ORANGE,22)
    UI.spacer(right,true)
    status = UI.label(right,"DIAGNÓSTICO PENDIENTE",13,UI.MUTED,20)
    run_button = UI.button(right,"EJECUTAR DIAGNÓSTICO",true)
    run_button.pressed.connect(_run_diagnostic)
    var footer = page["footer"]
    UI.button(footer,"← EDITAR NAVE",false,190).pressed.connect(func():get_tree().change_scene_to_file("res://scenes/engineering.tscn"))
    UI.spacer(footer)
    launch_button = UI.button(footer,"AUTORIZAR LANZAMIENTO  →",true,280)
    launch_button.disabled = true
    launch_button.pressed.connect(func():get_tree().change_scene_to_file("res://scenes/launch.tscn"))

func _run_diagnostic() -> void:
    run_button.disabled = true
    for i in range(6):
        status.text = "ANALIZANDO SISTEMA %d / 6" % (i+1)
        await get_tree().create_timer(0.18).timeout
    status.text = "6/6 PRUEBAS SUPERADAS" if verification["valid"] else "DIAGNÓSTICO NO APROBADO"
    status.add_theme_color_override("font_color",UI.GREEN if verification["valid"] else UI.RED)
    launch_button.disabled = not verification["valid"]
    run_button.disabled = false
