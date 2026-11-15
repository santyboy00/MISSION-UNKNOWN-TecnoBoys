extends Control
const UI = preload("res://scripts/ui_kit.gd")
const DB = preload("res://scripts/mission_data.gd")
const LaunchView = preload("res://scripts/launch_view.gd")
var rocket: Control
var indicator: Label
var action_button: Button
var launched: bool = false

func _ready() -> void:
    var mission = DB.MISSIONS[GameData.mission_id]
    var page = UI.page($Interface,"04 / DESPEGUE", "SECUENCIA DE LANZAMIENTO", "Sigue la cuenta regresiva y observa el ascenso de tu nave")
    var columns = UI.row(page["body"],12,true)
    var left = UI.panel(columns,1.0)
    UI.label(left,"CONTROL DE LANZAMIENTO",16,UI.CYAN)
    UI.label(left,"DESTINO",11,UI.MUTED)
    UI.label(left,mission["target"],28,UI.TEXT)
    UI.label(left,"VEHÍCULO",11,UI.MUTED)
    UI.label(left,DB.ROCKETS[GameData.rocket_id]["name"],22,UI.TEXT)
    UI.label(left,"Primero se activan los sistemas, después se produce el despegue y, finalmente, se transfiere el control a operaciones.",13,UI.MUTED)
    UI.spacer(left,true)
    indicator = UI.label(left,"SISTEMAS PREPARADOS · T - 3",14,UI.ORANGE)
    var art = UI.panel(columns,2.0)
    UI.label(art,"VENTANA DE LANZAMIENTO · VISTA ANIMADA",12,UI.CYAN)
    rocket = LaunchView.new()
    rocket.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    rocket.size_flags_vertical = Control.SIZE_EXPAND_FILL
    rocket.custom_minimum_size.y = 290
    rocket.clip_contents = true
    art.add_child(rocket)
    var footer = page["footer"]
    UI.button(footer,"← LABORATORIO",false,180).pressed.connect(func():get_tree().change_scene_to_file("res://scenes/laboratory.tscn"))
    UI.spacer(footer)
    action_button = UI.button(footer,"INICIAR LANZAMIENTO",true,260)
    action_button.pressed.connect(_action)

func _action() -> void:
    if not launched:
        launched = true
        rocket.active = true
        action_button.disabled = true
        SoundBus.play_launch()
    elif rocket.progress >= 1.0:
        GameData.begin_flight()
        get_tree().change_scene_to_file("res://scenes/flight.tscn")

func _process(_delta: float) -> void:
    if not launched or not is_instance_valid(indicator):
        return
    if rocket.seconds < 1.0:
        indicator.text = "T - 3 · SISTEMAS NOMINALES"
    elif rocket.seconds < 2.0:
        indicator.text = "T - 2 · INICIANDO PROPULSIÓN"
    elif rocket.seconds < 3.0:
        indicator.text = "T - 1 · PREPARADOS"
    elif rocket.seconds < 8.0:
        indicator.text = "DESPEGUE CONFIRMADO · ASCENSO"
    else:
        indicator.text = "ÓRBITA ALCANZADA · CONTINUAR"
        action_button.disabled = false
        action_button.text = "IR A CONTROL DE MISIÓN  →"
