extends Control
# Animación vectorial educativa: NO es un cálculo de trayectoria orbital.
# Se actualiza cada frame; el cohete interpola entre decisiones durante 2.4 s.
var progress: float = 0.02
var from_progress: float = 0.02
var to_progress: float = 0.02
var transit_time: float = 0.0
var transit_duration: float = 2.4
var in_transit: bool = false
var timer: float = 0.0
var target: String = "LUNA"
var target_color: Color = Color("#dc8369")
var event_visual: String = "thrusters"
var route_length: float = 100.0
var moving_back: bool = false

func start_transition(from_value: float, to_value: float, visual: String, new_length: float = 100.0) -> void:
    from_progress = clampf(from_value,0.0,1.0)
    to_progress = clampf(to_value,0.0,1.0)
    progress = from_progress
    transit_time = 0.0
    in_transit = true
    moving_back = to_progress < from_progress
    event_visual = visual
    route_length = new_length
    queue_redraw()

func _process(delta: float) -> void:
    timer += delta
    if in_transit:
        transit_time += delta
        var t: float = clampf(transit_time / transit_duration,0.0,1.0)
        var eased: float = t*t*(3.0-2.0*t)
        progress = lerpf(from_progress,to_progress,eased)
        if t >= 1.0:
            in_transit = false
    queue_redraw()

func _point(t: float) -> Vector2:
    var w: float = size.x
    var h: float = size.y
    var start: Vector2 = Vector2(w*.14,h*.66)
    var end: Vector2 = Vector2(w*.86,h*.51)
    var detour: float = clampf((route_length-100.0)*.32,-12.0,18.0)
    var a: Vector2 = Vector2(w*.32,h*.10+detour)
    var b: Vector2 = Vector2(w*.65,h*.16+detour)
    return start.bezier_interpolate(a,b,end,clampf(t,0,1))

func _draw() -> void:
    if size.x < 40.0 or size.y < 40.0:
        return
    var h: float = size.y
    var w: float = size.x
    var start: Vector2 = _point(0.0)
    var end: Vector2 = _point(1.0)
    var r: float = clampf(h*.17,15.0,31.0)
    var route: PackedVector2Array = PackedVector2Array()
    var travelled: PackedVector2Array = PackedVector2Array()
    for i in range(81):
        var t: float = float(i)/80.0
        route.append(_point(t))
        if t <= progress:
            travelled.append(_point(t))
    if travelled.size()<2:
        travelled.append(_point(.015))
    draw_polyline(route,Color("#2D7798"),2.0,true)
    draw_polyline(travelled,Color("#79EBD5"),3.3,true)
    draw_circle(start,r+4.0,Color("#22688D"))
    draw_circle(start,r,Color("#2F82B4"))
    draw_arc(start,r+4.0,0,TAU,36,Color("#75D4F4"),2.0,true)
    draw_circle(end,r*1.15+3,target_color.darkened(.42))
    draw_circle(end,r*1.15,target_color)
    if target == "VENUS":
        # Nubes amarillas en bandas, esquemáticas y animadas.
        for stripe in range(5):
            var yy: float = end.y - r*.65 + float(stripe)*r*.33
            var band_half: float = sqrt(maxf(0.0,(r*1.15)*(r*1.15)-(yy-end.y)*(yy-end.y)))
            draw_line(Vector2(end.x-band_half*.79,yy+sin(timer*.4+stripe)*1.2),Vector2(end.x+band_half*.79,yy+sin(timer*.4+stripe)*1.2),Color(1.0,.93,.73,.26),2.2,true)
    elif target == "MARTE":
        draw_circle(end+Vector2(-r*.28,-r*.16),r*.22,target_color.darkened(.18))
    elif target == "LUNA":
        for offset in [Vector2(-.22,-.16),Vector2(.30,.13),Vector2(-.08,.34)]:
            draw_circle(end+offset*r,r*.13,target_color.darkened(.22))
    draw_arc(end,r*1.15+3,0,TAU,40,target_color.lightened(.20),1.8,true)
    var nose: Vector2 = _point(progress)
    _draw_ship(nose)
    _draw_event(nose)
    var font: Font = ThemeDB.fallback_font
    var font_sz: int = 12
    draw_string(font,Vector2(maxf(8,start.x-25),h-10),"TIERRA",HORIZONTAL_ALIGNMENT_LEFT,100,font_sz,Color("#BBD9EC"))
    draw_string(font,Vector2(minf(w-70,end.x-27),h-10),target,HORIZONTAL_ALIGNMENT_LEFT,90,font_sz,Color("#FFD3B8"))

func _draw_ship(p: Vector2) -> void:
    var s: float = clampf(size.y/240.0,0.55,1.0)
    var p2: Vector2 = p + Vector2(0,sin(timer*3.0)*1.2)
    var tip: Vector2 = p2+Vector2(9,-4)*s
    var tail: Vector2 = p2+Vector2(-12,5)*s
    var wing: Vector2 = p2+Vector2(0,10)*s
    draw_colored_polygon(PackedVector2Array([tip,tail,wing]),Color("#F2F9FD"))
    draw_circle(p2,2.7*s,Color("#79E0F4"))
    var jet: float = (8.0+sin(timer*21.0)*2.3)*s
    draw_line(tail,tail+Vector2(-jet,5)*s,Color("#FFA875"),2.6,true)
    draw_circle(p2,12.0*s,Color(0.35,0.94,0.99,0.16))

func _draw_event(p: Vector2) -> void:
    var phase: float = timer
    match event_visual:
        "thrusters":
            for i in range(3):
                var q: float = 11+i*9+fposmod(phase*15,10)
                draw_arc(p,q,PI*.65,PI*1.4,20,Color(0.45,.91,1,.36),1.5,true)
        "eclipse":
            var shade: Vector2 = Vector2(size.x*.40+sin(phase*.7)*size.x*.07,size.y*.35)
            draw_circle(shade,23,Color(0.03,0.04,0.08,.90))
            draw_arc(shade,26,PI*.15,PI*1.78,28,Color(.66,.69,.85,.4),2,true)
        "signal":
            for i in range(3):
                draw_arc(p,17+i*9+fposmod(phase*6.0,9.0),-1.0,1.0,26,Color(.38,.92,1,.45),2,true)
        "thermal":
            for i in range(4):
                var py: float = fposmod(phase*25+i*15,68)
                draw_line(p+Vector2(i*9-15,-py),p+Vector2(i*9-11,-py-9),Color(1,.39,.22,.65),2,true)
        "meteors":
            for i in range(10):
                var xx: float = fposmod(size.x*1.25-phase*82-i*83,size.x+65)-30
                var yy: float = 15+i*17
                draw_line(Vector2(xx,yy),Vector2(xx-16,yy+10),Color(1,.79,.57,.73),2,true)
        "radiation":
            for i in range(5):
                var a: float = phase*1.9+TAU*float(i)/5.0
                var sp: Vector2 = p+Vector2.from_angle(a)*(22+4*sin(phase*3+i))
                draw_line(p,sp,Color(.92,.5,1,.42),1.5,true)
        "autopilot":
            var offset: float = sin(phase*7)*7
            draw_arc(p+Vector2(offset,0),23,0,TAU,32,Color(1,.65,.3,.57),2,true)
            draw_line(p+Vector2(-22,0),p+Vector2(22,0),Color(1,.65,.3,.40),1,true)
        "science":
            for i in range(4):
                var a: float = -.7+i*.33+sin(phase*.8)*.12
                draw_line(p,p+Vector2.from_angle(a)*65,Color(.35,1,.70,.32),1.6,true)
        "calibration":
            for i in range(3):
                draw_arc(p,14+i*13,phase*1.0,phase*1.0+PI*.85,26,Color(.39,1,.78,.47),2,true)
        "downlink":
            for i in range(4):
                var wave: float = 20+i*15+fposmod(phase*12,14)
                draw_arc(p,wave,-1.1,-.1,26,Color(.46,.87,1,.44),2,true)
