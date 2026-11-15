extends Control
# Despegue por fases: cuenta regresiva, ignición, ascenso y separación.
var progress: float = 0.0
var seconds: float = 0.0
var active: bool = false
var clock: float = 0.0
func _ready() -> void:
    clip_contents = true
func _process(delta: float) -> void:
    clock += delta
    if active and seconds < 8.0:
        seconds = minf(8.0,seconds+delta)
        progress = clampf((seconds-3.0)/5.0,0.0,1.0)
    queue_redraw()
func _draw() -> void:
    if size.x <= 10 or size.y <= 10:
        return
    var w: float = size.x
    var h: float = size.y
    var radius: float = w*.57
    var origin: Vector2 = Vector2(w*.56,h*1.35)
    draw_circle(origin,radius,Color("#153C5B"))
    draw_arc(origin,radius,PI,TAU,100,Color("#4AA8E3"),3.0,true)
    for i in range(40):
        var sx: float = fposmod(float(i*127),w)
        var sy: float = fposmod(float(i*67)+clock*(9+float(i%4)*8),h)
        draw_circle(Vector2(sx,sy),1.0,Color(.69,.86,1,.35))
    var shake: float = sin(clock*24)*2.3 if active and seconds>2.4 and seconds<4.7 else sin(clock*1.4)*1.3
    var x: float = w*.55+shake
    var yy: float = h*.65-progress*h*.86
    var center: Vector2 = Vector2(x,yy)
    var scale: float = minf(w/820.0,h/355.0)*1.25
    if active and seconds>2.35:
        # Humo bajo el motor, seguido por la columna principal de fuego.
        for i in range(22):
            var shift: float = fposmod(float(i*19)+clock*38,100.0)
            var cloud: Vector2 = center+Vector2(sin(float(i)*2.5+clock)*22,72+shift)*scale
            draw_circle(cloud,(4.5+float(i%4)*3)*scale,Color(.70,.81,.92,.13))
        var power: float = clampf((seconds-2.35)/.55,0,1)
        var flame_length: float = (46+sin(clock*26)*10+progress*42)*power
        draw_colored_polygon(PackedVector2Array([center+Vector2(-17,48)*scale,center+Vector2(0,75+flame_length)*scale,center+Vector2(17,48)*scale]),Color(1,.40,.18,.86))
        draw_colored_polygon(PackedVector2Array([center+Vector2(-10,48)*scale,center+Vector2(0,60+flame_length*.70)*scale,center+Vector2(10,48)*scale]),Color(1,.87,.44,.95))
        for i in range(16):
            var drift: float = fposmod(clock*92+i*17,120.0)
            var particle: Vector2 = center+Vector2(sin(clock*9+i*4)*18,66+drift)*scale
            draw_circle(particle,2.5*scale,Color(1,.7,.4,.55))
    var top: PackedVector2Array = PackedVector2Array([center+Vector2(-22,-57)*scale,center+Vector2(0,-90)*scale,center+Vector2(22,-57)*scale])
    draw_colored_polygon(top,Color("#EEF7FD"))
    draw_rect(Rect2(center+Vector2(-22,-57)*scale,Vector2(44,106)*scale),Color("#D5E7F3"))
    draw_rect(Rect2(center+Vector2(-22,-3)*scale,Vector2(44,10)*scale),Color("#F5A06C"))
    draw_circle(center+Vector2(0,-28)*scale,10.5*scale,Color("#1E5F7B"))
    draw_arc(center+Vector2(0,-28)*scale,10.5*scale,0,TAU,28,Color("#6ADDEA"),2.1,true)
    for side in [-1,1]:
        var s: float = float(side)
        var separation: float = maxf(0,seconds-5.0)
        var booster: Vector2 = center+Vector2(s*(29+separation*38),28+separation*32)*scale
        draw_colored_polygon(PackedVector2Array([booster+Vector2(-8,-24)*scale,booster+Vector2(8,-24)*scale,booster+Vector2(13,15)*scale,booster+Vector2(-13,15)*scale]),Color("#83ADC6"))
