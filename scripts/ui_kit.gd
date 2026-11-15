extends RefCounted
const TEXT = Color("#ECF6FF")
const MUTED = Color("#A0B9CD")
const CYAN = Color("#64DDE8")
const ORANGE = Color("#FFBE86")
const RED = Color("#FF7F91")
const GREEN = Color("#7BE2B7")
const SURFACE = Color(0.026, 0.055, 0.101, 0.95)

static func box_style(background: Color = SURFACE, border: Color = Color("#31506A"), radius: int = 12) -> StyleBoxFlat:
    var s = StyleBoxFlat.new()
    s.bg_color = background
    s.border_color = border
    s.set_border_width_all(1)
    s.set_corner_radius_all(radius)
    s.content_margin_left = 14
    s.content_margin_right = 14
    s.content_margin_top = 12
    s.content_margin_bottom = 12
    return s

static func clear(parent: Node) -> void:
    for child in parent.get_children():
        parent.remove_child(child)
        child.queue_free()

static func column(parent: Node, gap: int = 8, expand: bool = false) -> VBoxContainer:
    var c = VBoxContainer.new()
    c.add_theme_constant_override("separation", gap)
    c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    if expand:
        c.size_flags_vertical = Control.SIZE_EXPAND_FILL
    parent.add_child(c)
    return c

static func row(parent: Node, gap: int = 10, expand: bool = false) -> HBoxContainer:
    var c = HBoxContainer.new()
    c.add_theme_constant_override("separation", gap)
    c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    if expand:
        c.size_flags_vertical = Control.SIZE_EXPAND_FILL
    parent.add_child(c)
    return c

static func spacer(parent: Node, vertical: bool = false) -> Control:
    var s = Control.new()
    s.mouse_filter = Control.MOUSE_FILTER_IGNORE
    s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    if vertical:
        s.size_flags_vertical = Control.SIZE_EXPAND_FILL
    parent.add_child(s)
    return s

static func label(parent: Node, content: String, font_size: int = 14, color: Color = TEXT, min_height: int = 0, wrap: bool = true) -> Label:
    var l = Label.new()
    l.text = content
    # Cuerpo mínimo de 12 px para evitar las etiquetas diminutas de versiones previas.
    l.add_theme_font_size_override("font_size", maxi(font_size, 12))
    l.add_theme_color_override("font_color", color)
    l.vertical_alignment = VERTICAL_ALIGNMENT_TOP
    l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if wrap else TextServer.AUTOWRAP_OFF
    l.clip_text = false
    l.mouse_filter = Control.MOUSE_FILTER_IGNORE
    l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    l.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
    l.custom_minimum_size.y = float(max(min_height, maxi(font_size,12) + 8))
    parent.add_child(l)
    return l

static func button(parent: Node, content: String, primary: bool = false, width: int = 0) -> Button:
    var b = Button.new()
    b.text = content
    b.clip_text = true
    b.focus_mode = Control.FOCUS_ALL
    b.tooltip_text = content
    b.custom_minimum_size = Vector2(float(width), 40)
    b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    b.add_theme_font_size_override("font_size", 13)
    b.add_theme_color_override("font_color", Color("#07202E") if primary else TEXT)
    b.add_theme_color_override("font_hover_color", Color("#07202E") if primary else TEXT)
    b.add_theme_color_override("font_disabled_color", MUTED)
    b.add_theme_stylebox_override("normal", box_style(CYAN if primary else Color("#123047"), CYAN if primary else Color("#2C5570"), 8))
    b.add_theme_stylebox_override("hover", box_style(Color("#A4F4F1") if primary else Color("#23516B"), CYAN, 8))
    b.add_theme_stylebox_override("pressed", box_style(Color("#43B6C7") if primary else Color("#173F57"), CYAN, 8))
    b.add_theme_stylebox_override("disabled", box_style(Color("#1B2C3C"), Color("#34485B"), 8))
    b.add_theme_stylebox_override("focus", box_style(Color(0,0,0,0), CYAN, 8))
    parent.add_child(b)
    b.pressed.connect(SoundBus.play_click)
    return b

static func dropdown(parent: Node) -> OptionButton:
    var opt = OptionButton.new()
    opt.custom_minimum_size.y = 36
    opt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    opt.add_theme_font_size_override("font_size", 12)
    opt.add_theme_stylebox_override("normal", box_style(Color("#102E43"), Color("#34647D"), 8))
    parent.add_child(opt)
    return opt

static func panel(parent: Node, weight: float = 1.0, min_width: int = 0) -> VBoxContainer:
    var wrapper = PanelContainer.new()
    wrapper.custom_minimum_size.x = float(min_width)
    wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    wrapper.size_flags_vertical = Control.SIZE_EXPAND_FILL
    wrapper.size_flags_stretch_ratio = weight
    wrapper.add_theme_stylebox_override("panel", box_style())
    parent.add_child(wrapper)
    return column(wrapper, 9, true)

static func scroll_column(parent: Node) -> VBoxContainer:
    var scroll = ScrollContainer.new()
    scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    parent.add_child(scroll)
    var holder = VBoxContainer.new()
    holder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    holder.add_theme_constant_override("separation", 7)
    scroll.add_child(holder)
    return holder

static func bar_style(color: Color) -> StyleBoxFlat:
    var s = StyleBoxFlat.new()
    s.bg_color = color
    s.set_corner_radius_all(4)
    return s

static func stat_bar(parent: Node, name: String, value: float, max_value: float = 100.0, color: Color = CYAN) -> void:
    var group = column(parent, 3)
    var r = row(group, 4)
    label(r, name, 11, MUTED, 16, false)
    label(r, "%d / %d" % [roundi(value), roundi(max_value)], 11, TEXT, 16, false).size_flags_horizontal = Control.SIZE_SHRINK_END
    var bar = ProgressBar.new()
    bar.custom_minimum_size.y = 8
    bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    bar.min_value = 0
    bar.max_value = maxf(1.0, max_value)
    bar.value = clampf(value, 0, bar.max_value)
    bar.show_percentage = false
    bar.add_theme_stylebox_override("background", bar_style(Color("#213B50")))
    bar.add_theme_stylebox_override("fill", bar_style(color))
    group.add_child(bar)

static func page(root: Control, stage: String, title: String, subtitle: String) -> Dictionary:
    clear(root)
    var outer = MarginContainer.new()
    root.add_child(outer)
    outer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    outer.add_theme_constant_override("margin_left", 30)
    outer.add_theme_constant_override("margin_right", 30)
    outer.add_theme_constant_override("margin_top", 18)
    outer.add_theme_constant_override("margin_bottom", 18)
    var stack = column(outer, 12, true)
    var header = column(stack, 5)
    var h = row(header, 8)
    label(h, "MISSION: UNKNOWN", 17, TEXT, 24, false)
    label(h, stage, 11, CYAN, 18, false).size_flags_horizontal = Control.SIZE_SHRINK_END
    label(header, title, 23, TEXT, 32, false)
    label(header, subtitle, 12, MUTED, 18, true)
    var separator = ColorRect.new()
    separator.color = Color("#31506A")
    separator.custom_minimum_size.y = 1
    header.add_child(separator)
    # La cabecera y la navegación siempre quedan visibles. Solo desplaza el contenido.
    var content_scroll = ScrollContainer.new()
    content_scroll.name = "ContenidoDesplazable"
    content_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    content_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    content_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    content_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
    content_scroll.follow_focus = true
    content_scroll.scroll_vertical_custom_step = 42.0
    stack.add_child(content_scroll)
    var body = column(content_scroll, 10, false)
    body.name = "CuerpoDesplazable"
    body.custom_minimum_size.y = 0.0
    var footer = row(stack, 10)
    footer.name = "NavegacionSiempreVisible"
    footer.custom_minimum_size.y = 44
    return {"body":body, "footer":footer, "header":header, "scroll":content_scroll}


# Variante de página destinada a informes extensos.
# A diferencia de page(), todo el contenido (incluido el footer)
# pertenece a una página desplazable. El ScrollContainer tiene su
# propio alto acotado a la ventana y el contenido un mínimo mayor.
static func scrollable_page(root: Control, stage: String, title: String, subtitle: String, min_height: int = 940) -> Dictionary:
    clear(root)
    var outer = MarginContainer.new()
    root.add_child(outer)
    outer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    outer.add_theme_constant_override("margin_left", 25)
    outer.add_theme_constant_override("margin_right", 16)
    outer.add_theme_constant_override("margin_top", 14)
    outer.add_theme_constant_override("margin_bottom", 14)

    var page_scroll = ScrollContainer.new()
    page_scroll.name = "DesplazamientoDePagina"
    page_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    page_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    page_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    page_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
    page_scroll.follow_focus = true
    page_scroll.scroll_vertical_custom_step = 48.0
    outer.add_child(page_scroll)

    var scroll_bar: VScrollBar = page_scroll.get_v_scroll_bar()
    scroll_bar.custom_minimum_size.x = 12.0
    var base_track = StyleBoxFlat.new()
    base_track.bg_color = Color("#153046")
    base_track.set_corner_radius_all(6)
    scroll_bar.add_theme_stylebox_override("scroll", base_track)
    var thumb = StyleBoxFlat.new()
    thumb.bg_color = CYAN.darkened(0.2)
    thumb.set_corner_radius_all(6)
    scroll_bar.add_theme_stylebox_override("grabber", thumb)
    scroll_bar.add_theme_stylebox_override("grabber_highlight", thumb)
    scroll_bar.add_theme_stylebox_override("grabber_pressed", thumb)

    var stack = column(page_scroll, 12, false)
    stack.name = "ContenidoCompleto"
    stack.custom_minimum_size.y = float(maxi(min_height, 790))
    stack.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

    var header = column(stack, 5)
    var row_title = row(header, 8)
    label(row_title, "MISSION: UNKNOWN", 17, TEXT, 24, false)
    label(row_title, stage, 11, CYAN, 18, false).size_flags_horizontal = Control.SIZE_SHRINK_END
    label(header, title, 23, TEXT, 32, false)
    label(header, subtitle, 12, MUTED, 18, true)
    var separator = ColorRect.new()
    separator.color = Color("#31506A")
    separator.custom_minimum_size.y = 1
    header.add_child(separator)

    var body = column(stack, 10, true)
    body.size_flags_vertical = Control.SIZE_EXPAND_FILL
    var footer = row(stack, 10)
    footer.custom_minimum_size.y = 46
    return {"body":body, "footer":footer, "header":header, "scroll":page_scroll}
