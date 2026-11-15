extends Control
# Diagrama GEOMÉTRICO de una media elipse de Hohmann (modelo circular/coplanar).
# El reloj de la animación NO es una efeméride NASA ni una integración de 2 cuerpos.
const NASA = preload("res://scripts/nasa_data.gd")
var mission_id: int = 1
var clock: float = 0.0

func _process(delta: float) -> void:
    clock = fmod(clock+delta,12.0)
    queue_redraw()

func _draw() -> void:
    if size.x < 100.0 or size.y < 110.0:
        return
    var font: Font = ThemeDB.fallback_font
    var center: Vector2 = Vector2(size.x*0.5,size.y*0.53)
    if mission_id == 0:
        var e: Vector2 = Vector2(size.x*.20,size.y*.54)
        var m: Vector2 = Vector2(size.x*.78,size.y*.54)
        var ca: Vector2 = e + Vector2(size.x*.20,-size.y*.40)
        var cb: Vector2 = m + Vector2(-size.x*.20,-size.y*.40)
        var pts: PackedVector2Array = PackedVector2Array()
        for j in range(65):
            pts.append(e.bezier_interpolate(ca,cb,m,float(j)/64.0))
        draw_polyline(pts,Color("#52D9EF"),2.5,true)
        draw_circle(e,15,Color("#3DAAEF"))
        draw_circle(m,8,Color("#DDE3ED"))
        var t: float = (clock/12.0)
        draw_circle(e.bezier_interpolate(ca,cb,m,t),4.5,Color("#FFFFFF"))
        draw_string(font,e+Vector2(-22,31),"TIERRA",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("#BBD7EB"))
        draw_string(font,m+Vector2(-15,27),"LUNA",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("#BBD7EB"))
        draw_string(font,Vector2(6,size.y-7),"Referencia lunar · arco ilustrativo, no Hohmann solar",HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color("#9EBACA"))
        return
    var dest_au: float = NASA.orbit_au(mission_id)
    var max_radius: float = maxf(1.0,dest_au)
    var scale: float = minf((size.x-64.0)/(2.2*max_radius),(size.y-45.0)/(2.2*max_radius))
    var earth_r: float = scale
    var dest_r: float = scale*dest_au
    draw_arc(center,earth_r,0.0,TAU,96,Color("#315A80"),1.0,true)
    draw_arc(center,dest_r,0.0,TAU,96,Color("#6B5583"),1.0,true)
    var axis_a: float = (earth_r+dest_r)*0.5
    var axis_b: float = sqrt(earth_r*dest_r)
    var ellipse_center: Vector2 = center+Vector2((earth_r-dest_r)*0.5,0.0)
    var transfer: PackedVector2Array = PackedVector2Array()
    for j in range(97):
        var theta: float = PI*float(j)/96.0
        transfer.append(ellipse_center+Vector2(axis_a*cos(theta),-axis_b*sin(theta)))
    draw_polyline(transfer,Color("#60DFE5"),2.8,true)
    draw_circle(center,10,Color("#FCCC66"))
    var earth_pos: Vector2 = center+Vector2(earth_r,0.0)
    var dest_pos: Vector2 = center+Vector2(-dest_r,0.0)
    draw_circle(earth_pos,5.5,Color("#4CBEF9"))
    draw_circle(dest_pos,5.5,Color("#EEAA88"))
    var ship_theta: float = PI*(clock/12.0)
    var ship: Vector2 = ellipse_center+Vector2(axis_a*cos(ship_theta),-axis_b*sin(ship_theta))
    draw_circle(ship,4.0,Color("#FFFFFF"))
    draw_arc(ship,8,0.0,TAU,24,Color("#62E4D4"),1.0,true)
    draw_string(font,earth_pos+Vector2(-10,20),"T",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("#A8D8F1"))
    draw_string(font,dest_pos+Vector2(-9,20),"V" if mission_id==1 else "M",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("#F5C3A2"))
    draw_string(font,center+Vector2(9,16),"SOL",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("#FCCD78"))
    draw_string(font,Vector2(7,size.y-7),"Media elipse ideal · sin fechas ni velocidad a escala",HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color("#9EBACA"))
