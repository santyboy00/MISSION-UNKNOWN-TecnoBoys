extends Control
const UI = preload("res://scripts/ui_kit.gd")
const DB = preload("res://scripts/mission_data.gd")
const NASA = preload("res://scripts/nasa_data.gd")
var selection: int = 0

func _ready() -> void:
    _build()

func _build() -> void:
    var view = UI.page($Interface, "01 / MISIÓN", "SELECCIONA TU DESTINO", "Origen: TIERRA  ·  Destinos: LUNA, VENUS y MARTE  ·  Dificultad creciente")
    var cards = UI.row(view["body"], 12, true)
    for i in range(DB.MISSIONS.size()):
        var mission: Dictionary = DB.MISSIONS[i]
        var c = UI.panel(cards, 1.0)
        UI.label(c, "TIERRA  →  " + mission["target"], 12, UI.CYAN, 18)
        var picture = TextureRect.new()
        picture.texture = load(mission["image"])
        picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        picture.custom_minimum_size.y = 160
        picture.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        c.add_child(picture)
        UI.label(c, mission["name"], 19, UI.TEXT, 26)
        UI.label(c, mission["description"], 12, UI.MUTED, 44)
        UI.label(c,"DATOS NASA / JPL",11,UI.CYAN,16)
        if i == 0:
            UI.label(c,"Distancia media: 384 400 km · señal: 1.28 s",11,UI.MUTED,32)
        else:
            UI.label(c,"Hohmann ideal: %.0f días · %.0f W/m²" % [NASA.ideal_transfer_days(i), NASA.solar_flux_wm2(i)],11,UI.MUTED,32)
        UI.spacer(c, true)
        UI.label(c, "%s  ·  %s  ·  %d créditos" % [mission["code"], mission["difficulty"], mission["budget"]], 12, UI.ORANGE, 18)
        var b = UI.button(c, "SELECCIONADA ✓" if selection == i else "ELEGIR MISIÓN", selection == i)
        b.pressed.connect(_pick.bind(i))
    var footer = view["footer"]
    UI.button(footer, "← MENÚ", false, 140).pressed.connect(func():get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))
    UI.label(footer, "EQUIPO:", 12, UI.CYAN, 18).size_flags_horizontal = Control.SIZE_SHRINK_END
    var name = LineEdit.new()
    name.custom_minimum_size = Vector2(250, 40)
    name.text = GameData.team_name
    name.placeholder_text = "Nombre del equipo"
    name.max_length = 28
    name.add_theme_font_size_override("font_size", 13)
    name.add_theme_stylebox_override("normal", UI.box_style(Color("#103047"),UI.CYAN,8))
    footer.add_child(name)
    name.text_changed.connect(func(value: String): GameData.team_name = value)
    UI.label(footer,"JUGADORES:",11,UI.CYAN,18).size_flags_horizontal = Control.SIZE_SHRINK_END
    var players = SpinBox.new()
    players.min_value = 1
    players.max_value = 4
    players.step = 1
    players.value = GameData.crew_size
    players.custom_minimum_size = Vector2(78,38)
    players.value_changed.connect(func(v: float): GameData.crew_size = int(v))
    footer.add_child(players)
    UI.spacer(footer)
    UI.button(footer, "CONTINUAR  →", true, 170).pressed.connect(_continue)

func _pick(index: int) -> void:
    selection = index
    _build()

func _continue() -> void:
    GameData.choose_mission(selection)
    get_tree().change_scene_to_file("res://scenes/engineering.tscn")
