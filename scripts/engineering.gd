extends Control
const UI = preload("res://scripts/ui_kit.gd")
const DB = preload("res://scripts/mission_data.gd")
const Sim = preload("res://scripts/simulation.gd")
const NASA = preload("res://scripts/nasa_data.gd")
const Ground = preload("res://scripts/ground_network.gd")
const ShipView = preload("res://scripts/ship_view.gd")
var description: Label
var stats: VBoxContainer

func _ready() -> void:
    _build()

func _build() -> void:
    var mission: Dictionary = DB.MISSIONS[GameData.mission_id]
    var page = UI.page($Interface,"02 / INGENIERÍA", "CONSTRUYE TU NAVE", "Objetivo: " + mission["code"] + " · Cada módulo modifica costo, masa, energía y ciencia")
    var columns = UI.row(page["body"], 12, true)
    var left = UI.panel(columns, 0.99)
    UI.label(left,"01  COMPONENTES (10 MÓDULOS)",15,UI.CYAN)
    UI.label(left,"Selecciona los módulos del vehículo.",12,UI.MUTED)
    var list = UI.scroll_column(left)
    for component in DB.COMPONENTS:
        var selected = component["id"] in GameData.components
        var b = UI.button(list,("✓  " if selected else "+  ") + component["name"],selected)
        b.custom_minimum_size.y = 32
        b.add_theme_font_size_override("font_size",12)
        b.tooltip_text = component["description"]
        b.mouse_entered.connect(_inspect.bind(component))
        b.pressed.connect(_toggle.bind(component["id"]))
    var center = UI.panel(columns, 1.0)
    UI.label(center,"02  VISTA MODULAR",16,UI.CYAN)
    var ship = ShipView.new()
    ship.enabled_parts = GameData.components.duplicate()
    ship.mouse_filter = Control.MOUSE_FILTER_IGNORE
    ship.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    ship.size_flags_vertical = Control.SIZE_EXPAND_FILL
    ship.custom_minimum_size.y = 185
    center.add_child(ship)
    UI.label(center,"INFORMACIÓN DEL MÓDULO",12,UI.CYAN)
    description = UI.label(center,"Coloca el cursor sobre un módulo para conocer sus características.",12,UI.MUTED,92)
    var right = UI.panel(columns, 1.14)
    UI.label(right,"03  CONFIGURACIÓN",16,UI.CYAN)
    UI.label(right,"LANZADOR",11,UI.MUTED)
    var rocket = UI.dropdown(right)
    for r in DB.ROCKETS:
        rocket.add_item("%s · %s" % [r["name"],r["caption"]])
    rocket.select(GameData.rocket_id)
    rocket.item_selected.connect(_rocket_changed)
    UI.label(right,"ÓRBITA",11,UI.MUTED)
    var orbit = UI.dropdown(right)
    for o in DB.ORBITS:
        orbit.add_item(o["name"])
    orbit.select(GameData.orbit_id)
    orbit.item_selected.connect(_orbit_changed)
    UI.label(right,"SEGMENTO TERRESTRE / NASA DSN",11,UI.CYAN)
    var ground = UI.dropdown(right)
    for plan in Ground.PLANS:
        ground.add_item(str(plan["name"]))
    ground.select(GameData.ground_id)
    ground.item_selected.connect(_ground_changed)
    UI.label(right,"RECURSOS DISPONIBLES",12,UI.CYAN)
    stats = UI.scroll_column(right)
    _refresh_stats()
    var footer = page["footer"]
    UI.button(footer,"← MISIONES",false,150).pressed.connect(func():get_tree().change_scene_to_file("res://scenes/mission_select.tscn"))
    UI.spacer(footer)
    UI.button(footer,"IR AL LABORATORIO  →",true,250).pressed.connect(func():get_tree().change_scene_to_file("res://scenes/laboratory.tscn"))

func _refresh_stats() -> void:
    UI.clear(stats)
    var r = Sim.evaluate(GameData.config())
    var m = DB.MISSIONS[GameData.mission_id]
    var launch = DB.ROCKETS[GameData.rocket_id]
    UI.stat_bar(stats,"PRESUPUESTO",r["cost"],m["budget"],UI.RED if r["cost"]>m["budget"] else UI.CYAN)
    UI.stat_bar(stats,"MASA",r["mass"],launch["mass_limit"],UI.RED if r["mass"]>launch["mass_limit"] else UI.CYAN)
    UI.stat_bar(stats,"POTENCIAL CIENTÍFICO",r["science_potential"],m["science_min"],UI.GREEN)
    UI.label(stats,"Energía neta: %d" % r["power"],12,UI.GREEN if r["power"]>=12 else UI.RED)
    UI.label(stats,"Comunicación: %d" % r["comm"],12,UI.GREEN if r["comm"]>=m["comm"] else UI.RED)
    UI.label(stats,"Combustible: %d" % r["fuel"],12,UI.GREEN if r["fuel"]>=16 else UI.RED)
    UI.label(stats,"NASA: %.0f W/m² · panel modelo %.0f W" % [r["solar_flux"],r["panel_watts"]],11,UI.CYAN,22)
    UI.label(stats,"Tsiolkovski (hipótesis): Δv %.0f m/s" % r["onboard_delta_v_mps"],11,UI.ORANGE,22)
    UI.label(stats,"✓  DISEÑO VIABLE" if r["valid"] else "!  REQUIERE AJUSTES",13,UI.GREEN if r["valid"] else UI.RED)

func _toggle(id: String) -> void:
    if id in GameData.components:
        GameData.components.erase(id)
    else:
        GameData.components.append(id)
    GameData.save_game()
    _build()

func _inspect(c: Dictionary) -> void:
    if is_instance_valid(description):
        description.text = "%s\nCosto: %d | Masa: %d | Energía: %+d" % [c["description"], c["cost"], c["mass"], c["generation"]-c["consumption"]]

func _rocket_changed(index: int) -> void:
    GameData.rocket_id = index
    GameData.save_game()
    _refresh_stats()

func _orbit_changed(index: int) -> void:
    GameData.orbit_id = index
    GameData.save_game()
    _refresh_stats()

func _ground_changed(index: int) -> void:
    GameData.ground_id = index
    GameData.save_game()
    _refresh_stats()
