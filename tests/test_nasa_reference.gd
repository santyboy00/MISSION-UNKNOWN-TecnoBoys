extends SceneTree
# Ejecutar tras instalar Godot: godot --headless --path . --script res://tests/test_nasa_reference.gd
const DB=preload("res://scripts/mission_data.gd")
const NASA=preload("res://scripts/nasa_data.gd")
const Evidence=preload("res://scripts/science_evidence.gd")
const Sim=preload("res://scripts/simulation.gd")

func _initialize() -> void:
    assert(FileAccess.file_exists("res://scenes/data_explorer.tscn"))
    assert(FileAccess.file_exists("res://data/nasa_pds_catalog.json"))
    assert(FileAccess.file_exists("res://scripts/data_explorer.gd"))
    var s: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/nasa_pds_catalog.json"))
    assert(s.get("destinations",[]).size()==3)
    var flux_earth:float=NASA.SOLAR_AT_1AU
    assert(absf(NASA.solar_flux_wm2(1)-flux_earth / pow(NASA.VENUS_AU,2.0))<0.01)
    assert(absf(NASA.solar_flux_wm2(2)-flux_earth / pow(NASA.MARS_AU,2.0))<0.01)
    for mission in range(3):
        assert(Evidence.for_mission(mission).size()==3)
        var bound: Vector2=NASA.one_way_light_time_extremes_minutes(mission)
        assert(bound.x>0 and bound.y>=bound.x)
    print("PASS RECURSOS NASA V13: catalogo NASA; laboratorio; fuentes; radiacion; retardo")
    quit(0)
