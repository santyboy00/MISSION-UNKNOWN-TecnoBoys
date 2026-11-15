extends Control
const UI = preload("res://scripts/ui_kit.gd")

func _ready() -> void:
    var page = UI.page($Interface,"MANUAL", "CÓMO JUGAR", "Aprende el proceso de diseño, operación y evaluación")
    var grid = GridContainer.new()
    grid.columns=3
    grid.size_flags_horizontal=Control.SIZE_EXPAND_FILL
    grid.size_flags_vertical=Control.SIZE_EXPAND_FILL
    grid.add_theme_constant_override("h_separation",12)
    grid.add_theme_constant_override("v_separation",12)
    page["body"].add_child(grid)
    var entries = [
        ["01 · OBJETIVO", "Despegas desde la Tierra hacia la Luna, Venus o Marte. Cada misión tiene requisitos propios."],
        ["02 · INGENIERÍA", "Configura instrumentos, energía, masa, cohete y órbita."],
        ["03 · LABORATORIO", "Valida los seis requisitos antes de despegar."],
        ["04 · LANZAMIENTO", "Inicia la secuencia y observa la animación de la nave."],
        ["05 · OPERACIONES", "Resuelve diez eventos. Tus decisiones cambian los recursos."],
        ["06 · REWIND", "Compara decisiones alternativas y exporta una bitácora."]
    ]
    for entry in entries:
        var card=UI.panel(grid,1.0)
        UI.label(card,entry[0],16,UI.CYAN)
        UI.label(card,entry[1],13,UI.MUTED)
    var footer=page["footer"]
    UI.button(footer,"← VOLVER",false,140).pressed.connect(func():get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))
    UI.spacer(footer)
    UI.label(footer,"NASA/JPL PARA ÓRBITAS Y SOL · REGLAS DE JUEGO SEPARADAS",11,UI.ORANGE)
    UI.button(footer,"INICIAR MISIÓN  →",true,190).pressed.connect(func():get_tree().change_scene_to_file("res://scenes/mission_select.tscn"))
