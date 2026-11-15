extends SceneTree
# Ejecutar con: godot --headless --path . --script res://tests/test_scroll_layout.gd
const UI = preload("res://scripts/ui_kit.gd")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var root = Control.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.size = Vector2(1280.0, 720.0)
    self.root.add_child(root)
    var page = UI.scrollable_page(root, "07 / INFORME", "BITÁCORA DE LA MISIÓN", "Prueba de accesibilidad", 940)
    var sides = UI.row(page["body"], 12, true)
    var left = UI.panel(sides, 1.6)
    UI.label(left, "PRUEBA DE HISTORIAL", 14, UI.CYAN)
    var items = UI.scroll_column(left)
    for i in range(10):
        var card = UI.panel(items, 1.0)
        card.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
        UI.label(card, "Incidente %d" % i, 12)
        UI.label(card, "Prueba de consecuencia", 12)
    var right = UI.panel(sides, 1.0)
    for i in range(13):
        UI.label(right, "Resultado de simulación línea %d" % i, 14, UI.TEXT, 30)
    var back = UI.button(page["footer"], "← RESULTADOS", false, 170)
    UI.spacer(page["footer"])
    var export = UI.button(page["footer"], "EXPORTAR .TXT", true, 180)
    await process_frame
    await process_frame
    var scroll: ScrollContainer = page["scroll"]
    var bar: VScrollBar = scroll.get_v_scroll_bar()
    assert(bar.visible, "Debe verse la segunda barra vertical")
    assert(bar.max_value > bar.page, "Debe existir espacio para desplazarse")
    scroll.scroll_vertical = int(bar.max_value - bar.page)
    await process_frame
    assert(back.size.y >= 40 and export.size.y >= 40, "Botones deben conservar tamaño")
    assert(export.get_global_rect().position.y >= -1, "Exportar debe quedar dentro de la ventana al bajar")
    assert(export.get_global_rect().end.y <= 724, "Exportar debe quedar visible al bajar")
    print("PASS: scroll exterior, scroll interior, botones accesibles a 1280x720")
    quit(0)
