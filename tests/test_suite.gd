extends SceneTree
# Ejecutar con Godot instalado: godot --headless --path . --script res://tests/test_suite.gd
const DB = preload("res://scripts/mission_data.gd")
const Sim = preload("res://scripts/simulation.gd")
const NASA = preload("res://scripts/nasa_data.gd")
const Ground = preload("res://scripts/ground_network.gd")
const Evidence = preload("res://scripts/science_evidence.gd")

func _initialize() -> void:
    assert(DB.MISSIONS.size() == 3)
    assert(DB.COMPONENTS.size() == 10)
    assert(DB.EVENTS.size() == 10)
    assert(Ground.PLANS.size() == 3)
    assert(DB.MISSIONS[0]["target"] == "LUNA")
    assert(DB.MISSIONS[1]["target"] == "VENUS")
    assert(DB.MISSIONS[2]["target"] == "MARTE")
    assert(absf(NASA.ideal_transfer_days(1) - 146.08) < 1.0)
    assert(absf(NASA.ideal_transfer_days(2) - 258.87) < 1.0)
    assert(absf(NASA.solar_flux_wm2(1) - 2600.85) < 15.0)
    assert(absf(NASA.solar_flux_wm2(2) - 586.12) < 15.0)
    assert(NASA.panel_watts(NASA.VENUS_AU) > NASA.panel_watts(NASA.MARS_AU))
    assert(NASA.rocket_delta_v_mps(120.0, 75.0) > 0.0)
    assert(NASA.rocket_delta_v_mps(120.0, 150.0) > NASA.rocket_delta_v_mps(120.0, 75.0))
    for id in range(3):
        var light: Vector2 = NASA.one_way_light_time_extremes_minutes(id)
        assert(light.x > 0.0 and light.y >= light.x)
    var configs: Array = [
        {"mission_id":0,"rocket_id":1,"orbit_id":0,"ground_id":1,"components":["solar","battery","camera","antenna"]},
        {"mission_id":1,"rocket_id":1,"orbit_id":0,"ground_id":1,"components":["solar","battery","camera","antenna","spectro"]},
        {"mission_id":2,"rocket_id":2,"orbit_id":0,"ground_id":1,"components":["solar","battery","camera","antenna","spectro","shield"]}
    ]
    var wins: Array = [[0,1,2,0,0,2,0,0,2,2],[0,0,0,0,1,2,1,2,0,1],[0,0,0,0,1,2,2,1,0,2]]
    var losses: Array = [[2,2,1,0,0,1,2,1,1,0],[0,2,0,0,2,0,1,0,0,2],[0,0,1,1,0,2,0,1,2,1]]
    for i in range(3):
        var base: Dictionary = Sim.evaluate(configs[i])
        assert(base["valid"],"Debe ser viable la configuración inicial")
        assert(base["onboard_delta_v_mps"] > 0.0)
        assert(base["panel_watts"] > 0.0)
        var winner: Dictionary = Sim.replay(configs[i],wins[i])
        var loser: Dictionary = Sim.replay(configs[i],losses[i])
        assert(winner == Sim.replay(configs[i],wins[i]))
        assert(not Sim.is_failure(winner))
        assert(Sim.score(winner,configs[i])["success"])
        assert(Sim.is_failure(loser))
        assert(float(winner["day"]) >= NASA.ideal_transfer_days(i))
        assert(Sim.risk_level(winner,configs[i]) >= 0.0)
        assert(Sim.risk_level(winner,configs[i]) <= 100.0)
        var records: Array = Evidence.for_mission(i)
        assert(records.size() == 3,"Cada destino debe contener 3 evidencias NASA")
        for record in records:
            assert(record.has("source") and str(record["source"]).begins_with("https://"))
            assert(record.has("instrument"))
            assert(int(record["answer"]) >= 0 and int(record["answer"]) <= 2)
            assert(Evidence.observation_score(record,int(record["answer"]),[record["instrument"]]) == 10)
            assert(Evidence.observation_score(record,int(record["answer"]),[]) == 3)
        var poor_plan: Dictionary = configs[i].duplicate(true)
        poor_plan["ground_id"] = 0
        var strong_plan: Dictionary = configs[i].duplicate(true)
        strong_plan["ground_id"] = 2
        assert(Sim.evaluate(strong_plan)["comm"] > Sim.evaluate(poor_plan)["comm"])
        assert(Sim.evaluate(strong_plan)["cost"] > Sim.evaluate(poor_plan)["cost"])
    for scene_path in [
        "res://scenes/main_menu.tscn","res://scenes/mission_select.tscn",
        "res://scenes/engineering.tscn","res://scenes/laboratory.tscn",
        "res://scenes/launch.tscn","res://scenes/flight.tscn",
        "res://scenes/science_analysis.tscn","res://scenes/results.tscn",
        "res://scenes/debrief.tscn","res://scenes/nasa_sources.tscn",
        "res://scenes/knowledge_lab.tscn","res://scenes/tutorial.tscn"]:
        assert(FileAccess.file_exists(scene_path),"Escena ausente: " + scene_path)
    print("PASS V11: NASA/JPL; 3 misiones; 10 eventos; 9 evidencias; ganar/perder; DSN; física ideal")
    quit(0)
