extends SceneTree
# Ejecutar: godot --headless --path . --script res://tests/ui_smoke_v13.gd
# Verifica creación de widgets y navegación visible; no sustituye inspección visual humana.
const Sim=preload("res://scripts/simulation.gd")
var failures: Array[String]=[]

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var gd: Node=root.get_node_or_null("GameData")
    if gd == null:
        push_error("Autoload GameData ausente")
        quit(1)
        return
    # No ejecutar choose_mission(): eso sobrescribiría el guardado del usuario.
    gd.set("mission_id",0)
    gd.set("rocket_id",1)
    gd.set("orbit_id",0)
    gd.set("ground_id",1)
    gd.set("components",["solar","battery","camera","antenna"])
    gd.set("decisions",[])
    gd.set("science_answers",[])
    gd.set("science_done",false)
    var config:Dictionary=gd.call("config")
    gd.set("flight_state",Sim.initial_state(config))
    gd.set("launched",true)
    gd.set("completed",true)
    var files:Array[String]=[
        "main_menu","mission_select","engineering","laboratory","launch","nasa_sources",
        "data_explorer","science_analysis","numeric_lab","results","debrief","knowledge_lab","tutorial"
    ]
    for base in files:
        gd.set("science_done",base=="numeric_lab")
        var scene_path:String="res://scenes/%s.tscn" % base
        var resource:PackedScene=load(scene_path)
        if resource == null:
            failures.append(base+": escena no pudo cargarse")
            continue
        var instance:Node=resource.instantiate()
        root.add_child(instance)
        await process_frame
        await process_frame
        var ui:Node=instance.get_node_or_null("Interface")
        if ui==null or ui.get_child_count()==0:
            failures.append(base+": interfaz sin contenido")
        else:
            var foot:Node=instance.find_child("NavegacionSiempreVisible",true,false)
            if base!="debrief" and foot==null:
                failures.append(base+": footer fijo ausente")
            if foot!=null and foot is Control:
                var rect:Rect2=foot.get_global_rect()
                if rect.position.y+rect.size.y>730:
                    failures.append(base+": botones de navegación fuera del viewport")
        root.remove_child(instance)
        instance.queue_free()
        await process_frame
    if failures.is_empty():
        print("PASS: humo de escenas y pies de navegación V13")
        quit(0)
    else:
        for f in failures:
            push_error(f)
        quit(1)
