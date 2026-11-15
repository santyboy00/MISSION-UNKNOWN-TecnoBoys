extends Control
# Laboratorio reproducible sin Internet: los semiejes NASA/JPL y la constante solar
# permanecen fijos; el deslizador es un ESCENARIO HIPOTÉTICO, no efemérides reales.
const UI = preload("res://scripts/ui_kit.gd")
const NASA = preload("res://scripts/nasa_data.gd")
const Orbit = preload("res://scripts/orbital_view.gd")
var distance: HSlider
var distance_label: Label
var flux_label: Label
var light_label: Label
var model_label: Label
var meter: ProgressBar
var chosen: int = 1
var orbital_drawing: Control

func _ready() -> void:
    var page: Dictionary = UI.page($Interface,"OBSERVATORIO / NASA", "EXPLORA UN MODELO FÍSICO", "Parámetros orbitales publicados + fórmulas auditables. Mueve el deslizador para experimentar.")
    var body: HBoxContainer = UI.row(page["body"],12,true)
    var left: VBoxContainer = UI.panel(body,1.3)
    UI.label(left,"DATOS ORBITALES DE REFERENCIA",17,UI.CYAN,26)
    var pick: OptionButton = UI.dropdown(left)
    pick.add_item("LUNA · órbita terrestre como referencia")
    pick.add_item("VENUS · JPL 0.72333566 UA")
    pick.add_item("MARTE · JPL 1.52371034 UA")
    pick.select(1)
    pick.item_selected.connect(_choose)
    UI.label(left,"IRRADIANCIA A UNA DISTANCIA HIPOTÉTICA",13,UI.ORANGE,24)
    distance=HSlider.new()
    distance.min_value=0.5
    distance.max_value=2.0
    distance.step=0.01
    distance.custom_minimum_size.y=30
    left.add_child(distance)
    distance.value_changed.connect(_update)
    distance_label=UI.label(left,"",15,UI.TEXT,24)
    flux_label=UI.label(left,"",22,UI.CYAN,34)
    meter=ProgressBar.new()
    meter.min_value=0
    meter.max_value=5600
    meter.show_percentage=false
    meter.custom_minimum_size.y=22
    meter.add_theme_stylebox_override("background",UI.bar_style(Color("#254159")))
    meter.add_theme_stylebox_override("fill",UI.bar_style(UI.GREEN))
    left.add_child(meter)
    UI.label(left,"FÓRMULA: F(r) = 1360.8 W/m² × (1 UA / r)²",14,UI.TEXT,26)
    UI.label(left,"El experimento demuestra la ley del inverso del cuadrado. NO estima sombras, eficiencia de baterías ni orientación real.",12,UI.MUTED,52)
    UI.spacer(left,true)
    UI.button(left,"FUENTE NASA/JPL · POTENCIA SOLAR  ↗",false).pressed.connect(func(): OS.shell_open("https://www.jpl.nasa.gov/edu/resources/lesson-plan/calculating-solar-power-in-space/"))
    var right: VBoxContainer = UI.panel(body,1.0)
    UI.label(right,"TIEMPO, LUZ Y TRANSFERENCIAS",17,UI.CYAN,26)
    orbital_drawing=Orbit.new()
    orbital_drawing.mission_id=chosen
    orbital_drawing.custom_minimum_size.y=175
    orbital_drawing.size_flags_horizontal=Control.SIZE_EXPAND_FILL
    right.add_child(orbital_drawing)
    model_label=UI.label(right,"",13,UI.TEXT,84)
    light_label=UI.label(right,"",13,UI.ORANGE,72)
    UI.label(right,"¿QUÉ VIENE DE NASA / JPL?",13,UI.CYAN,22)
    UI.label(right,"Semiejes orbitales, distancia lunar, constante de irradiancia y velocidad de la luz. El tiempo Hohmann se calcula con órbitas circulares idealizadas.",12,UI.TEXT,91)
    UI.label(right,"¿QUÉ ES SOLO UNA HIPÓTESIS?",13,UI.ORANGE,22)
    UI.label(right,"La distancia que eliges en el deslizador, los puntos de recursos, costos y riesgos del juego. No hay fechas de lanzamiento calculadas.",12,UI.MUTED,83)
    UI.spacer(right,true)
    UI.button(right,"VER ARCHIVOS Y FUENTES NASA  ↗",false).pressed.connect(func(): OS.shell_open("https://ode.rsl.wustl.edu/"))
    var footer: HBoxContainer=page["footer"]
    UI.button(footer,"← MENÚ",false,140).pressed.connect(func():get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))
    UI.spacer(footer)
    UI.button(footer,"TABLA DE FUENTES →",false,200).pressed.connect(func():get_tree().change_scene_to_file("res://scenes/nasa_sources.tscn"))
    UI.button(footer,"DISEÑAR MISIÓN →",true,185).pressed.connect(func():get_tree().change_scene_to_file("res://scenes/mission_select.tscn"))
    distance.value=NASA.orbit_au(chosen)
    _update(distance.value)

func _choose(idx: int) -> void:
    chosen=idx
    if orbital_drawing != null:
        orbital_drawing.mission_id=idx
    distance.value=NASA.orbit_au(chosen)
    _update(distance.value)

func _update(new_value: float) -> void:
    distance_label.text="Distancia de escenario: %.2f UA" % new_value
    var flux: float=NASA.SOLAR_AT_1AU / (new_value * new_value)
    flux_label.text="%.0f W/m² · %.2f veces la Tierra" % [flux,flux/NASA.SOLAR_AT_1AU]
    meter.value=flux
    if chosen==0:
        model_label.text="LUNA | distancia media NASA: %.0f km. Viaje histórico de referencia: 3 días (no Hohmann heliocéntrico)." % NASA.MOON_DISTANCE_KM
        light_label.text="Retardo radio una vía: %.2f segundos; calculado con velocidad de la luz." % NASA.lunar_signal_seconds()
    else:
        var label_planet: String="VENUS" if chosen==1 else "MARTE"
        model_label.text="%s · semieje mayor JPL: %.5f UA. Hohmann ideal: %.1f días. No incluye ventanas ni inserción." % [label_planet,NASA.orbit_au(chosen),NASA.ideal_transfer_days(chosen)]
        var bounds: Vector2=NASA.one_way_light_time_extremes_minutes(chosen)
        light_label.text="Tiempo de luz entre órbitas circulares: %.1f–%.1f min (una vía; no es distancia real de hoy)." % [bounds.x,bounds.y]
