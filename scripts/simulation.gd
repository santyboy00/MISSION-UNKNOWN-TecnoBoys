extends RefCounted
# Modelo lúdico y determinista, NO modelo orbital certificado.
const DB = preload("res://scripts/mission_data.gd")
const NASA = preload("res://scripts/nasa_data.gd")
const Ground = preload("res://scripts/ground_network.gd")

static func difficulty(config: Dictionary) -> float:
    return [1.0, 1.16, 1.30][clampi(int(config["mission_id"]), 0, 2)]

static func evaluate(config: Dictionary) -> Dictionary:
    var mission: Dictionary = DB.MISSIONS[config["mission_id"]]
    var rocket: Dictionary = DB.ROCKETS[config["rocket_id"]]
    var orbit: Dictionary = DB.ORBITS[config["orbit_id"]]
    var selected: Array = config["components"]
    var ground: Dictionary = Ground.plan(int(config.get("ground_id",1)))
    var cost: int = int(rocket["cost"]) + int(ground["cost"])
    var mass: int = 34
    var power: int = 0
    # NASA/JPL inverse-square solar flux. Convert to conservative educational
    # generation factor; not watts or measured panel performance.
    var solar_factor: float = 0.45 + 0.55 * clampf(NASA.solar_ratio(int(config["mission_id"])), 0.4, 1.6)
    var communication: int = 15 + int(ground["comm"])
    var instruments: int = 0
    for c in DB.COMPONENTS:
        if c["id"] in selected:
            cost += int(c["cost"])
            mass += int(c["mass"])
            if c["id"] == "solar":
                power += roundi(float(c["generation"]) * solar_factor)
            else:
                power += int(c["generation"])
            power -= int(c["consumption"])
            communication += int(c["comm"])
            instruments += int(c["science"])
    var science: int = roundi(float(instruments) * float(orbit["science_mult"]))
    var fuel: int = int(rocket["fuel"] - mission["transfer"] - orbit["fuel"])
    var checks: Array = [
        {"name":"PRESUPUESTO", "ok":cost <= mission["budget"], "detail":"%d / %d créditos" % [cost,mission["budget"]]},
        {"name":"MASA / LANZADOR", "ok":mass <= rocket["mass_limit"], "detail":"%d / %d unidades" % [mass,rocket["mass_limit"]]},
        {"name":"BALANCE ELÉCTRICO", "ok":power >= 12, "detail":"%d unidades netas (mín. 12)" % power},
        {"name":"COMUNICACIONES", "ok":communication >= mission["comm"], "detail":"%d / %d de cobertura" % [communication,mission["comm"]]},
        {"name":"RESERVA DE COMBUSTIBLE", "ok":fuel >= 16, "detail":"%d unidades disponibles" % fuel},
        {"name":"INSTRUMENTOS CIENTÍFICOS", "ok":science >= mission["science_min"], "detail":"%d / %d de potencial" % [science,mission["science_min"]]}
    ]
    var valid: bool = true
    for check in checks:
        if not check["ok"]:
            valid = false
    return {"cost":cost,"mass":mass,"power":power,"comm":communication,"science_potential":science,"fuel":fuel,"checks":checks,"valid":valid,"budget_left":mission["budget"]-cost,
        "nasa_ideal_days":NASA.ideal_transfer_days(int(config["mission_id"])),
        "solar_flux":NASA.solar_flux_wm2(int(config["mission_id"])),
        "solar_factor":solar_factor,
        "ground_capacity":ground["capacity"],
        "panel_watts":NASA.panel_watts(NASA.orbit_au(int(config["mission_id"]))) if "solar" in selected else 0.0,
        "onboard_delta_v_mps":NASA.rocket_delta_v_mps(float(mass),maxf(0.0,float(fuel))*2.0)}

static func initial_state(config: Dictionary) -> Dictionary:
    var initial: Dictionary = evaluate(config)
    var m: Dictionary = DB.MISSIONS[config["mission_id"]]
    return {
        "fuel":float(initial["fuel"]),
        "power":float(clampf(58.0 + float(initial["power"])*0.4,0.0,100.0)),
        "signal":float(clampf(initial["comm"],0,100)),
        "hull":100.0,
        "science":float(initial["science_potential"])*0.5,
        "day":0.0,
        "progress":0,
        "route_goal":100.0,
        "nasa_ideal_days":NASA.ideal_transfer_days(int(config["mission_id"])),
        "solar_flux":NASA.solar_flux_wm2(int(config["mission_id"])),
        "route_length":100.0,
        "route_progress":0.0,
        "route_spent":0.0,
        "science_done":false,
        "science_review":0,
        "downlink_capacity":float(initial["ground_capacity"]),
        "delay_days":0.0,
        "onboard_delta_v_mps":float(initial["onboard_delta_v_mps"]),
        "delta_v_initial_mps":float(initial["onboard_delta_v_mps"]),
        "delta_v_used_mps":0.0,
        "last_burn_delta_v_mps":0.0,
        "dataset_done":false,
        "dataset_points":0,
        "credits_left":float(initial["budget_left"]),
        "failed":false,
        "failure_reason":"",
        "last_event_visual":"thrusters",
        "last_event_tag":"NAVEGACIÓN",
        "log":[]
    }

static func route_fraction(state: Dictionary) -> float:
    return clampf(float(state.get("route_progress",0.0)) / maxf(1.0,float(state.get("route_length",100.0))),0.0,1.0)

static func visual_fraction(state: Dictionary) -> float:
    # El dibujo mantiene animación hasta el último incidente, aunque el progreso
    # de ingeniería ya sea suficiente para llegar. No altera la evaluación.
    var total: int = DB.EVENTS.size()
    var cap: float = 0.05 + float(state.get("progress",0)) / float(total) * 0.90
    if int(state.get("progress",0)) >= total:
        return route_fraction(state)
    return minf(route_fraction(state), cap)

static func risk_level(state: Dictionary, config: Dictionary) -> float:
    var base_fuel: float = maxf(20.0,float(evaluate(config)["fuel"]))
    var fuel_risk: float = 100.0*(1.0-clampf(float(state["fuel"])/base_fuel,0.0,1.0))
    var power_risk: float = 100.0-clampf(float(state["power"]),0.0,100.0)
    var signal_risk: float = 100.0-clampf(float(state["signal"]),0.0,100.0)
    var hull_risk: float = 100.0-clampf(float(state["hull"]),0.0,100.0)
    var mission: Dictionary = DB.MISSIONS[config["mission_id"]]
    var time_risk: float = maxf(0.0,float(state["day"])/float(mission["days"])-0.85)*75.0
    var deviation_risk: float = maxf(0.0,float(state.get("route_length",100.0))-100.0)*1.2
    return clampf(maxf(maxf(fuel_risk*0.74,power_risk*0.86),maxf(hull_risk*1.12,signal_risk*0.85)) + time_risk*0.25 + deviation_risk*0.45,0.0,100.0)

static func is_failure(state: Dictionary) -> bool:
    return bool(state.get("failed",false))

static func failure_reason(state: Dictionary) -> String:
    return str(state.get("failure_reason",""))

static func _fail(state: Dictionary, cause: String) -> void:
    state["failed"] = true
    state["failure_reason"] = cause

static func apply_choice(state: Dictionary, event_index: int, choice_index: int, config: Dictionary) -> Dictionary:
    var out: Dictionary = state.duplicate(true)
    if is_failure(out) or event_index < 0 or event_index >= DB.EVENTS.size():
        return out
    var event: Dictionary = DB.EVENTS[event_index]
    var option: Dictionary = event["options"][clampi(choice_index,0,2)]
    var effects: Dictionary = option["effects"]
    var hard: float = difficulty(config)
    var thermal_penalty: float = float(DB.MISSIONS[config["mission_id"]].get("thermal_penalty", 1.0))
    var signal_penalty: float = float(DB.MISSIONS[config["mission_id"]].get("signal_penalty", 1.0))
    var chosen: Array = config["components"]
    var old_route: float = route_fraction(out)
    var fuel_before: float = float(out["fuel"])
    var route_eff: float = float(effects.get("route",0))
    var time_adj: float = float(effects.get("days",0))
    var mission: Dictionary = DB.MISSIONS[config["mission_id"]]
    out["last_event_tag"] = event["tag"]
    out["last_event_visual"] = event["visual"]
    for key in ["fuel","power","signal","hull","science"]:
        var delta: float = float(effects.get(key,0))
        # Dificultad general; Venus penaliza los fallos térmicos y Marte
        # los fallos de comunicaciones. Estas son reglas educativas, no física orbital.
        if delta < 0.0 and key != "science":
            delta *= hard
            if event["tag"] == "TÉRMICO" and key in ["hull", "power"]:
                delta *= thermal_penalty
            if event["tag"] == "COMUNICACIONES" and key == "signal":
                delta *= signal_penalty
        out[key] = float(out.get(key,0.0)) + delta
    # El diseño inicial modifica las opciones y las sinergias.
    var special: String = str(option.get("special",""))
    if special == "shield":
        if "shield" in chosen:
            out["hull"] = float(out["hull"]) - 2.0
            route_eff += 3.0
        else:
            out["hull"] = float(out["hull"]) - 14.0 * hard
            route_eff -= 8.0
    elif special == "thruster":
        if "thruster" in chosen:
            route_eff += 8.0
            # Propulsores instalados mejoran precisión, no generan combustible.
            route_eff += 3.0
        else:
            out["hull"] = float(out["hull"]) - 10.0 * hard
            route_eff -= 7.0
    elif special == "instruments":
        if "spectro" in chosen and "camera" in chosen:
            out["science"] = float(out["science"]) + 10.0
        else:
            out["science"] = float(out["science"]) - 11.0
    elif special == "storage":
        if "storage" in chosen:
            out["science"] = float(out["science"]) + 12.0
    elif special == "downlink":
        if "antenna" not in chosen:
            out["signal"] = float(out["signal"]) - 8.0*hard
            out["science"] = float(out["science"]) - 10.0
    if event["tag"] == "COMUNICACIONES" and choice_index == 0 and "antenna" not in chosen:
        out["signal"] = float(out["signal"]) - 12.0*hard
        route_eff -= 7.0
    if event["tag"] == "CIENCIA" and "storage" in chosen:
        out["science"] = float(out["science"]) + 8.0
    if event_index == 0 and "thruster" in chosen:
        route_eff += 4.0
        # Bonificación de navegación, jamás de combustible.
        route_eff += 2.0
    if float(out["power"]) < 24.0:
        out["signal"] = float(out["signal"]) - 5.0*hard
        route_eff -= 5.0
    if float(out["signal"]) < 24.0:
        out["science"] = float(out["science"]) - 6.0
        route_eff -= 5.0
    if float(out["hull"]) < 38.0:
        route_eff -= 6.0
        time_adj += 2.0
    # Tsiolkovski: capacidad de maniobra restante después de consumir propelente.
    # 1 unidad del juego = 2 kg hipotéticos de propelente; masa de diseño = masa seca hipotética.
    var dry_mass: float = float(evaluate(config)["mass"])
    var initial_dv: float = float(out.get("delta_v_initial_mps",NASA.rocket_delta_v_mps(dry_mass,maxf(fuel_before,0.0)*2.0)))
    var dv_before: float = NASA.rocket_delta_v_mps(dry_mass,maxf(fuel_before,0.0)*2.0)
    var dv_after: float = NASA.rocket_delta_v_mps(dry_mass,maxf(float(out["fuel"]),0.0)*2.0)
    out["onboard_delta_v_mps"] = dv_after
    out["last_burn_delta_v_mps"] = maxf(0.0,dv_before-dv_after)
    out["delta_v_used_mps"] = maxf(0.0,initial_dv-dv_after)
    # El Δv efectivamente gastado contribuye un poco a la corrección; no dicta toda la órbita.
    if route_eff > 0.0 and float(out["last_burn_delta_v_mps"]) > 0.0:
        route_eff += minf(3.0,float(out["last_burn_delta_v_mps"])/80.0)
    # 100 unidades es la distancia nominal didáctica para los tres destinos.
    # Las decisiones cambian la longitud restante y el avance de cada etapa.
    var stage_distance: float = 100.0 / float(DB.EVENTS.size())
    var movement: float = maxf(0.5, stage_distance + route_eff*0.17 - (hard-1.0)*1.3)
    out["route_progress"] = float(out["route_progress"]) + movement
    out["route_length"] = clampf(float(out["route_length"]) - route_eff*0.16,78.0,158.0)
    out["route_spent"] = float(out["route_spent"]) + movement
    # La transferencia Hohmann ideal fija el mínimo. Las decisiones solo
    # reducen demoras evitables; NUNCA hacen el viaje más rápido que Hohmann.
    var ideal_days: float = float(out["nasa_ideal_days"])
    var delay_change: float = maxf(0.0, 2.6 + float(time_adj) * 0.42 - route_eff*0.115)
    var timescale: float = 0.18 if int(config["mission_id"]) == 0 else ideal_days/170.0
    out["delay_days"] = float(out.get("delay_days",0.0)) + delay_change*timescale
    out["day"] = ideal_days * float(event_index+1) / float(DB.EVENTS.size()) + float(out["delay_days"])
    out["science"] = maxf(0.0,float(out["science"]))
    for k in ["power","signal","hull"]:
        out[k] = clampf(float(out[k]),0.0,100.0)
    out["progress"] = event_index + 1
    out["log"].append({
        "event":event["title"],"decision":option["title"],"details":option["desc"],
        "day":float(out["day"]),"route_before":old_route,"route_after":visual_fraction(out),"effect":route_eff
    })
    if float(out["fuel"]) < 0.0:
        _fail(out,"Combustible agotado: no se puede completar una maniobra crítica.")
    elif float(out["power"]) <= 0.0:
        _fail(out,"Apagón total: el sistema eléctrico dejó de responder.")
    elif float(out["signal"]) <= 0.0:
        _fail(out,"Pérdida definitiva del enlace con el centro de control.")
    elif float(out["hull"]) <= 0.0:
        _fail(out,"Daños estructurales irreversibles en la nave.")
    elif float(out["day"]) > float(mission["days"])*1.45:
        _fail(out,"Se agotó la ventana operativa por demoras acumuladas.")
    elif int(out["progress"]) >= DB.EVENTS.size() and route_fraction(out) < 0.72:
        _fail(out,"La trayectoria se desvió demasiado: la nave no llegó al objetivo.")
    return out

static func replay(config: Dictionary, decisions: Array) -> Dictionary:
    var result: Dictionary = initial_state(config)
    for i in range(mini(decisions.size(),DB.EVENTS.size())):
        result = apply_choice(result,i,clampi(int(decisions[i]),0,2),config)
        if is_failure(result):
            break
    return result

static func score(state: Dictionary, config: Dictionary) -> Dictionary:
    var budget: Dictionary = evaluate(config)
    var m: Dictionary = DB.MISSIONS[config["mission_id"]]
    var route: float = route_fraction(state)
    var science: float = clampf(float(state["science"])/maxf(1.0,float(m["science_min"]))*73.0,0.0,100.0)
    var technical: float = clampf(float(state["hull"])*0.55 + float(state["power"])*0.45,0.0,100.0)
    var fuel_fraction: float = clampf(float(state["fuel"])/maxf(1.0,float(budget["fuel"])),0.0,1.0)
    var resources: float = clampf(fuel_fraction*48.0 + float(state["power"])*0.30 + clampf(float(state["credits_left"])/maxf(1.0,float(m["budget"])),0.0,1.0)*22.0,0.0,100.0)
    var risk: float = clampf(100.0-risk_level(state,config),0.0,100.0)
    var overall: int = roundi(science*.34 + technical*.25 + resources*.19 + risk*.15 + route*100.0*.07)
    # La fase científica pesa un 20% en una misión completada:
    # 80% ingeniería, 10% interpretación de fuentes NASA, 10% cálculos de tabla NASA.
    # No hacer los ejercicios equivale a 0 puntos en ese apartado; no hay incentivo a omitirlos.
    # La misión fallida conserva tope 24 puntos sin atribuirse telemetría inexistente.
    if int(state.get("progress",0)) >= DB.EVENTS.size() and not is_failure(state):
        overall = roundi(float(overall)*0.80 + float(state.get("science_review",0))/30.0*10.0 + float(state.get("dataset_points",0))/15.0*10.0)
    var achieved: bool = not is_failure(state) and int(state["progress"]) >= DB.EVENTS.size() and route >= .91 and float(state["science"]) >= float(m["science_min"]) and float(state["power"])>=6.0 and float(state["hull"])>=25.0 and float(state["signal"])>=19.0 and float(state["fuel"])>=0.0
    if is_failure(state):
        overall = mini(overall,24)
    elif not achieved:
        overall = mini(overall,59)
    var grade: String = "MISIÓN CUMPLIDA" if achieved else ("MISIÓN PERDIDA" if is_failure(state) else "MISIÓN PARCIAL")
    return {
        "overall":overall,"science":roundi(science),"tech":roundi(technical),"resources":roundi(resources),
        "risk":roundi(risk),"risk_percent":roundi(risk_level(state,config)),"success":achieved,"grade":grade,
        "route_ratio":route,"route_length":float(state.get("route_length",100.0)),"mission_days":float(state["day"]),
        "evidence_score":int(state.get("science_review",0)),
        "ideal_days":float(state.get("nasa_ideal_days",0.0)),
        "onboard_delta_v_mps":float(state.get("onboard_delta_v_mps",0.0)),
        "delta_v_used_mps":float(state.get("delta_v_used_mps",0.0)),
        "dataset_score":int(state.get("dataset_points",0))
    }

# NOVA: explicación contextual basada en telemetría; no es IA generativa.
static func advice(state: Dictionary) -> String:
    if is_failure(state):
        return "Fallo crítico. Consulta el informe y usa MISSION REWIND."
    if float(state.get("power",100.0)) < 25.0:
        return "ALERTA: reserva de energía muy baja; limita cargas no esenciales."
    if float(state.get("fuel",100.0)) < 18.0:
        return "ALERTA: poco combustible para maniobras futuras."
    if float(state.get("signal",100.0)) < 35.0:
        return "ALERTA: enlace débil; prioriza orientación y transmisión."
    if float(state.get("hull",100.0)) < 45.0:
        return "ALERTA: daños acumulados; evita exposición adicional."
    return "Subsistemas estables; compara recursos antes de la siguiente maniobra."
