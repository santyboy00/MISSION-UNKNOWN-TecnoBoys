extends Control
var enabled_parts: Array = ["solar", "battery", "camera", "antenna"]
var exhaust: float = 0.0
var rotation_amount: float = 0.0
var ticking: float = 0.0

func _ready() -> void:
    clip_contents = true

func _process(delta: float) -> void:
    ticking += delta
    rotation_amount = sin(ticking * 0.9) * 0.02
    exhaust = (0.18 + 0.10 * (sin(ticking * 7.5) * 0.5 + 0.5)) if ("thruster" in enabled_parts) else 0.0
    queue_redraw()

func _draw() -> void:
    var c = size / 2.0 + Vector2(0, sin(ticking * 1.8) * 6.0)
    var scale_factor = minf(size.x / 480.0, size.y / 310.0) * 0.88
    draw_set_transform(c, rotation_amount, Vector2(scale_factor,scale_factor))
    draw_arc(Vector2.ZERO,140,0,TAU,100,Color("#193e55"),1.3,true)
    draw_arc(Vector2.ZERO,107,0,TAU,100,Color("#123347"),1.0,true)
    draw_line(Vector2(-160,0),Vector2(160,0),Color("#194154"),1.5,true)
    draw_line(Vector2(0,-130),Vector2(0,130),Color("#194154"),1.5,true)
    if "solar" in enabled_parts:
        for s in [-1,1]:
            var x = 80*s
            draw_rect(Rect2(x-34,-38,68,76),Color("#183b65"),true)
            draw_rect(Rect2(x-34,-38,68,76),Color("#76a9db"),false,2)
            for k in range(1,4):
                draw_line(Vector2(x-34,-38+k*19),Vector2(x+34,-38+k*19),Color("#447ca9"),1.2)
            draw_line(Vector2(34*s,0),Vector2(46*s,0),Color("#c7d6e6"),4)
    if exhaust > 0.0:
        var flame_len = 22 + exhaust * 45 + sin(ticking*24)*7
        draw_colored_polygon(PackedVector2Array([Vector2(-20,44), Vector2(0,44+flame_len), Vector2(20,44)]),Color(0.28,0.83,1,0.77))
        draw_colored_polygon(PackedVector2Array([Vector2(-9,45), Vector2(0,45+flame_len*.67), Vector2(9,45)]),Color("#fff3a7"))
    draw_colored_polygon(PackedVector2Array([Vector2(-24,-45),Vector2(24,-45),Vector2(31,38),Vector2(-31,38)]),Color("#bdcad5"))
    draw_colored_polygon(PackedVector2Array([Vector2(-24,-45),Vector2(0,-72),Vector2(24,-45)]),Color("#f4f9fa"))
    draw_rect(Rect2(-23,-38,46,70),Color("#e9f0f4"),true)
    draw_rect(Rect2(-18,-35,36,62),Color("#6d899d"),false,2)
    draw_rect(Rect2(-18,4,36,8),Color("#ed9e65"),true)
    draw_circle(Vector2(0,-23),9,Color("#16354e"))
    draw_arc(Vector2(0,-23),9,0,TAU,32,Color("#9be0ee"),2)
    if "battery" in enabled_parts:
        draw_rect(Rect2(-12,16,24,11),Color("#85ebc4"),true)
    if "spectro" in enabled_parts:
        draw_rect(Rect2(-10,-48,20,11),Color("#eead6b"),true)
    if "antenna" in enabled_parts:
        var wiggle = sin(ticking * 2.0) * 2.5
        draw_line(Vector2(18,-41),Vector2(56,-75 + wiggle),Color("#d7e5ef"),2.5)
        draw_arc(Vector2(58,-76 + wiggle),14,PI*.9,PI*1.9,25,Color("#84def0"),2.3)
        draw_circle(Vector2(55,-76 + wiggle),2.5,Color("#8feef8"))
    if "camera" in enabled_parts:
        draw_rect(Rect2(-8,-65,16,9),Color("#23415c"),true)
        draw_circle(Vector2(0,-64),4,Color("#63dff0"))
    if "shield" in enabled_parts:
        draw_arc(Vector2.ZERO,89,0,TAU,96,Color(0.39,0.9,0.95,0.42),2.2,true)
    if "thruster" in enabled_parts:
        draw_rect(Rect2(-33,24,12,15),Color("#e7af7b"),true)
        draw_rect(Rect2(21,24,12,15),Color("#e7af7b"),true)
    if "storage" in enabled_parts:
        draw_rect(Rect2(-12,29,24,7),Color("#f0da82"),true)
    if "radar" in enabled_parts:
        # Radar esquemático lateral: refleja la elección modular.
        draw_line(Vector2(-27,-20),Vector2(-55,-47),Color("#B2F1DA"),2.5,true)
        draw_arc(Vector2(-60,-49),12,PI*.1,PI*.94,24,Color("#B2F1DA"),2.5,true)
        draw_arc(Vector2(-60,-49),18,PI*.1,PI*.94,24,Color(0.4,1.0,0.7,0.35),1.3,true)
    if "neutron" in enabled_parts:
        # Detector de neutrones, indicador lateral violeta.
        draw_rect(Rect2(-40,3,11,19),Color("#9A86F3"),true)
        draw_circle(Vector2(-34,10),3,Color("#E4C9FF"))
        draw_arc(Vector2(-34,10),14,PI,TAU,22,Color(0.68,0.57,1.0,0.45),1.5,true)
    draw_set_transform(Vector2.ZERO)
