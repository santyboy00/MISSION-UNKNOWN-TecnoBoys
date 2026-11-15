extends SceneTree
# TEST NATIVO GODOT: ejecutar con Godot 4.5+: 
# godot --headless --path . --script res://tests/test_v13_engine.gd
const Facts=preload("res://scripts/planetary_facts.gd")
const Sim=preload("res://scripts/simulation.gd")
const DB=preload("res://scripts/mission_data.gd")

func _initialize() -> void:
    var rows: Dictionary=Facts.read_all()
    assert(rows.size()==4,"Faltan mediciones NASA de cuatro cuerpos")
    assert(absf(float(rows["MARTE"]["gravity_m_s2"])-3.7)<0.01)
    assert(absf(float(rows["VENUS"]["irradiance_w_m2"])-2601.3)<0.1)
    for mission in range(3):
        for task_index in range(3):
            var task: Dictionary=Facts.task(mission,task_index)
            assert(task["options"].size()==3)
            assert(Facts.score(int(task["right"]),mission,task_index)==5)
            assert(Facts.score((int(task["right"])+1)%3,mission,task_index)==0)
        var modules: Array=["solar","battery","camera","antenna"]
        if mission>0:
            modules.append("spectro")
        if mission==2:
            modules.append("shield")
        var config: Dictionary={"mission_id":mission,"rocket_id":2 if mission==2 else 1,"orbit_id":0,"ground_id":1,"components":modules}
        assert(Sim.evaluate(config)["valid"]==true)
        var state: Dictionary=Sim.initial_state(config)
        for i in range(DB.EVENTS.size()):
            var next: Dictionary=Sim.apply_choice(state,i,1,config)
            assert(float(next["fuel"])<=float(state["fuel"])+0.001,"Combustible creado sin recarga")
            assert(float(next["onboard_delta_v_mps"])<=float(state["onboard_delta_v_mps"])+0.01,"Delta-v creció sin recarga")
            assert(float(next["delta_v_used_mps"])>=-0.001)
            state=next
            if Sim.is_failure(state):
                break
    print("PASS GODOT V13: datos NASA, tres misiones, respuestas, sin combustible ficticio y delta-v monotónico")
    quit(0)
