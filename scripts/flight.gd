extends Control
const UI = preload("res://scripts/ui_kit.gd")
const DB = preload("res://scripts/mission_data.gd")
const Sim = preload("res://scripts/simulation.gd")
const NASA = preload("res://scripts/nasa_data.gd")
const Trajectory = preload("res://scripts/trajectory_view.gd")
var map: Control
var telemetry: VBoxContainer
var incident: VBoxContainer
var current_index: int = 0

func _ready() -> void:
    if GameData.flight_state.is_empty():
        GameData.begin_flight()
    _render()

func _render() -> void:
    current_index = GameData.decisions.size()
    if current_index >= DB.EVENTS.size() or GameData.is_failed():
        if GameData.completed and not GameData.is_failed() and not GameData.science_done:
            get_tree().change_scene_to_file("res://scenes/science_analysis.tscn")
        else:
            get_tree().change_scene_to_file("res://scenes/results.tscn")
        return
    var state: Dictionary = GameData.flight_state
    var mission: Dictionary = DB.MISSIONS[GameData.mission_id]
    var event: Dictionary = DB.EVENTS[current_index]
    var page: Dictionary = UI.page($Interface,"OPERACIONES %d / %d" % [current_index+1,DB.EVENTS.size()],"CENTRO DE CONTROL","Equipo %s · %s · Día %.1f" % [GameData.team_name,mission["target"],state["day"]])
    var body: VBoxContainer = page["body"]
    var overview: HBoxContainer = UI.row(body,12,true)
    overview.size_flags_stretch_ratio = .95
    var trajectory_panel: VBoxContainer = UI.panel(overview,1.85)
    UI.label(trajectory_panel,"TRAYECTORIA ILUSTRATIVA · %s" % event["tag"],12,UI.CYAN,18)
    map = Trajectory.new()
    map.target = mission["target"]
    map.target_color = mission["color"]
    map.progress = Sim.visual_fraction(state)
    map.route_length = float(state.get("route_length",100.0))
    map.event_visual = str(event["visual"])
    map.custom_minimum_size.y = 103
    map.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    map.size_flags_vertical = Control.SIZE_EXPAND_FILL
    map.clip_contents = true
    trajectory_panel.add_child(map)
    UI.label(trajectory_panel,"Transferencia ideal %.0f días · demora simulada +%.1f días" % [NASA.ideal_transfer_days(GameData.mission_id),float(state.get("delay_days",0.0))],11,UI.MUTED,21)
    var signal_delay: Vector2 = NASA.one_way_light_time_extremes_minutes(GameData.mission_id)
    var delay_info: String = "Retardo Tierra-Luna de radio: %.2f s (un sentido)" % NASA.lunar_signal_seconds() if GameData.mission_id == 0 else "Latencia geométrica aproximada: %.1f–%.1f min (una vía; NO en tiempo real)" % [signal_delay.x, signal_delay.y]
    UI.label(trajectory_panel,delay_info,11,UI.CYAN,23)
    telemetry = UI.panel(overview,1.05)
    _refresh_telemetry()
    incident = UI.panel(body,1.4)
    _render_question(event)
    UI.label(page["footer"],"RUTA DINÁMICA: LAS DECISIONES CAMBIAN DESVÍOS, DURACIÓN, RIESGO Y CIENCIA.",11,UI.MUTED,18)
    SoundBus.play_event(str(event["visual"]))

func _refresh_telemetry() -> void:
    UI.clear(telemetry)
    var state: Dictionary = GameData.flight_state
    var risk: float = Sim.risk_level(state,GameData.config())
    var color: Color = UI.GREEN if risk < 35.0 else (UI.ORANGE if risk < 65.0 else UI.RED)
    UI.label(telemetry,"TELEMETRÍA  ·  RIESGO %d%%" % roundi(risk),13,color,18)
    # La latencia depende de geometría: se muestra en la tarjeta de trayectoria, no en las barras de salud.
    var risk_gauge: ProgressBar = ProgressBar.new()
    risk_gauge.custom_minimum_size.y = 7.0
    risk_gauge.show_percentage = false
    risk_gauge.min_value = 0.0
    risk_gauge.max_value = 100.0
    risk_gauge.value = risk
    risk_gauge.add_theme_stylebox_override("background", UI.bar_style(Color("#213B50")))
    risk_gauge.add_theme_stylebox_override("fill", UI.bar_style(color))
    telemetry.add_child(risk_gauge)
    UI.stat_bar(telemetry,"ENERGÍA",float(state["power"]),100,UI.CYAN)
    UI.stat_bar(telemetry,"INTEGRIDAD",float(state["hull"]),100,UI.GREEN)
    UI.stat_bar(telemetry,"COMUNICACIÓN",float(state["signal"]),100,UI.ORANGE)
    UI.label(telemetry,"COMB. %.0f · Δv DISP. %.0f m/s" % [state["fuel"],state.get("onboard_delta_v_mps",0.0)],11,UI.TEXT,19)

func _render_question(event: Dictionary) -> void:
    UI.clear(incident)
    UI.label(incident,"INCIDENTE %02d / %s" % [current_index+1,event["tag"]],12,UI.ORANGE,18)
    if GameData.crew_size > 1:
        UI.label(incident,"VOTACIÓN LOCAL: integrante %d de %d · mayorías; empate = primer voto" % [GameData.pending_votes.size()+1,GameData.crew_size],11,UI.CYAN,18)
    UI.label(incident,event["title"],17,UI.TEXT,24)
    UI.label(incident,event["story"],12,UI.MUTED,38)
    var choices: HBoxContainer = UI.row(incident,9,true)
    for i in range(3):
        var option: Dictionary = event["options"][i]
        var card: VBoxContainer = UI.panel(choices,1.0)
        UI.label(card,"%d · %s" % [i+1,option["title"]],12,UI.TEXT,30)
        UI.label(card,option["desc"],11,UI.MUTED,45)
        UI.spacer(card,true)
        UI.button(card,"TOMAR DECISIÓN %d" % [i+1],false).pressed.connect(_choose.bind(i))

func _choose(choice: int) -> void:
    var event: Dictionary = DB.EVENTS[current_index]
    var old: Dictionary = GameData.flight_state.duplicate(true)
    var resolved: bool = GameData.cast_vote(choice)
    if not resolved:
        _render()
        return
    var new_state: Dictionary = GameData.flight_state
    map.start_transition(Sim.visual_fraction(old),Sim.visual_fraction(new_state),str(event["visual"]),float(new_state["route_length"]))
    _refresh_telemetry()
    UI.clear(incident)
    UI.label(incident,"RESULTADO DE TU DECISIÓN",16,UI.CYAN,25)
    UI.label(incident,str(event["options"][choice]["title"]),17,UI.TEXT,28)
    UI.label(incident,str(event["options"][choice]["desc"]),12,UI.MUTED,40)
    var before: float = Sim.visual_fraction(old)*100.0
    var after: float = Sim.visual_fraction(new_state)*100.0
    UI.label(incident,"Avance: %.0f%% → %.0f%%   ·   Ruta efectiva: %.0f unidades" % [before,after,new_state["route_length"]],13,UI.GREEN if after>before else UI.ORANGE,22)
    UI.label(incident,"Energía: %.0f → %.0f   |   Casco: %.0f → %.0f   |   Combustible: %.0f → %.0f" % [old["power"],new_state["power"],old["hull"],new_state["hull"],old["fuel"],new_state["fuel"]],12,UI.MUTED,22)
    UI.label(incident,"Maniobra: %.0f m/s de Δv gastado · %.0f m/s restante (vehículo ficticio)" % [new_state.get("last_burn_delta_v_mps",0.0),new_state.get("onboard_delta_v_mps",0.0)],11,UI.CYAN,20)
    UI.label(incident,"NOVA: " + Sim.advice(new_state) + "  |  " + str(event["fact"]),11,UI.CYAN,46)
    if GameData.is_failed():
        UI.label(incident,"MISIÓN PERDIDA: " + GameData.failure_reason(),12,UI.RED,30)
    UI.spacer(incident,true)
    var actions: HBoxContainer = UI.row(incident,10)
    UI.spacer(actions)
    if GameData.is_failed():
        UI.button(actions,"VER CAUSA DEL FRACASO  →",true,280).pressed.connect(_next)
        SoundBus.play_event("failure")
    elif GameData.completed:
        UI.button(actions,"ANALIZAR DATOS NASA  →",true,255).pressed.connect(_next)
    else:
        UI.button(actions,"SIGUIENTE EVENTO  →",true,230).pressed.connect(_next)
        SoundBus.play_event(str(event["visual"]))

func _next() -> void:
    _render()
