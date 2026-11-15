extends Node
const DB = preload("res://scripts/mission_data.gd")
const Ground = preload("res://scripts/ground_network.gd")
const Sim = preload("res://scripts/simulation.gd")
const SAVE_PATH = "user://mission_unknown_v13_save.json"
const LEGACY_SAVE_PATH = "user://mission_unknown_v11_save.json"

var team_name: String = "EQUIPO AURORA"
var mission_id: int = 0
var rocket_id: int = 1
var orbit_id: int = 0
var ground_id: int = 1
var crew_size: int = 1
var pending_votes: Array = []
var science_answers: Array = []
var science_done: bool = false
var science_correct: int = 0
var science_points: int = 0
var dataset_answers: Array = []
var dataset_done: bool = false
var dataset_points: int = 0
var dataset_correct: int = 0
var forensic_points: int = 0 # Solo aprendizaje posterior a una misión fallida; no cuenta como telemetría.
var components: Array = ["solar", "battery", "camera", "antenna"]
var decisions: Array = []
var flight_state: Dictionary = {}
var completed: bool = false
var launched: bool = false
var quiz_before: int = -1
var quiz_after: int = -1
var quiz_mode: String = "before"

func set_quiz_result(phase: String, amount: int) -> void:
    if phase == "after":
        quiz_after = amount
    else:
        quiz_before = amount
    save_game()

func choose_mission(index: int) -> void:
    mission_id = index
    rocket_id = 2 if index == 2 else 1
    orbit_id = 0
    ground_id = 1
    pending_votes = []
    science_answers = []
    science_done = false
    science_correct = 0
    science_points = 0
    dataset_answers = []
    dataset_done = false
    dataset_points = 0
    dataset_correct = 0
    forensic_points = 0
    components = ["solar", "battery", "camera", "antenna"]
    if index >= 1:
        components.append("spectro")
    if index == 2:
        components.append("shield")
    decisions = []
    flight_state = {}
    completed = false
    launched = false
    save_game()

func config() -> Dictionary:
    return {"mission_id": mission_id, "rocket_id": rocket_id, "orbit_id": orbit_id, "ground_id": ground_id, "components": components.duplicate()}

func begin_flight() -> void:
    launched = true
    decisions = []
    flight_state = Sim.initial_state(config())
    pending_votes = []
    science_answers = []
    science_done = false
    science_correct = 0
    science_points = 0
    dataset_answers = []
    dataset_done = false
    dataset_points = 0
    dataset_correct = 0
    forensic_points = 0
    completed = false
    save_game()

func is_failed() -> bool:
    return Sim.is_failure(flight_state)

func failure_reason() -> String:
    return Sim.failure_reason(flight_state)

func make_decision(option_index: int) -> void:
    if decisions.size() >= DB.EVENTS.size() or is_failed():
        return
    flight_state = Sim.apply_choice(flight_state, decisions.size(), option_index, config())
    decisions.append(option_index)
    pending_votes = []
    completed = decisions.size() >= DB.EVENTS.size() or is_failed()
    save_game()

func replay_with_change(event_index: int, alternative: int) -> Dictionary:
    var alt_decisions = decisions.duplicate()
    if event_index >= 0 and event_index < alt_decisions.size():
        alt_decisions[event_index] = alternative
    var result: Dictionary = Sim.replay(config(), alt_decisions)
    if science_done and not Sim.is_failure(result) and int(result.get("progress",0)) >= DB.EVENTS.size():
        result["science_review"] = science_points
        result["science_done"] = true
    if dataset_done and not Sim.is_failure(result):
        result["dataset_done"] = true
        result["dataset_points"] = dataset_points
    return result

func has_save() -> bool:
    return FileAccess.file_exists(SAVE_PATH) or FileAccess.file_exists(LEGACY_SAVE_PATH)

func save_game() -> void:
    var output = {"version": 13, "dataset_answers": dataset_answers, "dataset_done": dataset_done, "dataset_points": dataset_points, "dataset_correct": dataset_correct, "ground_id": ground_id, "crew_size": crew_size, "pending_votes": pending_votes, "science_answers": science_answers, "science_done": science_done, "science_correct": science_correct, "science_points": science_points, "forensic_points": forensic_points, "team_name": team_name, "mission_id": mission_id, "rocket_id": rocket_id, "orbit_id": orbit_id, "components": components, "decisions": decisions, "completed": completed, "launched": launched, "quiz_before":quiz_before, "quiz_after":quiz_after}
    var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(output))

func load_game() -> bool:
    if not has_save():
        return false
    var path: String = SAVE_PATH if FileAccess.file_exists(SAVE_PATH) else LEGACY_SAVE_PATH
    var file = FileAccess.open(path, FileAccess.READ)
    if file == null:
        return false
    var parsed = JSON.parse_string(file.get_as_text())
    if not (parsed is Dictionary):
        return false
    team_name = str(parsed.get("team_name", "EQUIPO AURORA")).substr(0, 28)
    mission_id = clampi(int(parsed.get("mission_id", 0)), 0, 2)
    rocket_id = clampi(int(parsed.get("rocket_id", 1)), 0, 2)
    orbit_id = clampi(int(parsed.get("orbit_id", 0)), 0, 2)
    ground_id = clampi(int(parsed.get("ground_id", 1)), 0, 2)
    crew_size = clampi(int(parsed.get("crew_size",1)),1,4)
    pending_votes = parsed.get("pending_votes",[])
    if pending_votes.size() >= crew_size:
        pending_votes = []
    science_answers = parsed.get("science_answers",[])
    science_done = bool(parsed.get("science_done",false))
    science_correct = int(parsed.get("science_correct",0))
    science_points = int(parsed.get("science_points",0))
    dataset_answers = parsed.get("dataset_answers",[])
    dataset_done = bool(parsed.get("dataset_done",false))
    dataset_points = int(parsed.get("dataset_points",0))
    dataset_correct = int(parsed.get("dataset_correct",0))
    forensic_points = int(parsed.get("forensic_points",0))
    components = parsed.get("components", []).duplicate()
    decisions = []
    var saved = parsed.get("decisions", [])
    for decision in saved:
        if decisions.size() < DB.EVENTS.size():
            decisions.append(clampi(int(decision), 0, 2))
    launched = bool(parsed.get("launched", decisions.size() > 0))
    flight_state = Sim.replay(config(), decisions) if launched else {}
    completed = decisions.size() >= DB.EVENTS.size() or is_failed()
    if science_done and not is_failed() and not flight_state.is_empty():
        flight_state["science_review"] = science_points
        flight_state["science_done"] = true
    if dataset_done and not is_failed() and not flight_state.is_empty():
        flight_state["dataset_done"] = true
        flight_state["dataset_points"] = dataset_points
    quiz_before = int(parsed.get("quiz_before", -1))
    quiz_after = int(parsed.get("quiz_after", -1))
    return true

func register_science_choice(index: int, option: int, earned: int, was_correct: bool) -> void:
    if index != science_answers.size() or science_done:
        return
    science_answers.append(option)
    var capacity: int = int(Ground.plan(ground_id)["capacity"])
    if is_failed():
        # Acceso al archivo público NASA: solo medimos comprensión; NO hay datos de sonda recuperados.
        forensic_points += 10 if was_correct else 0
    else:
        var allowed: int = maxi(0,capacity-science_points)
        science_points += mini(earned,allowed)
    if was_correct:
        science_correct += 1
    if science_answers.size() >= 3:
        science_done = true
        if not is_failed():
            flight_state["science_done"] = true
            flight_state["science_review"] = science_points
    save_game()

# Colaboración local 1–4: cada integrante vota en el mismo dispositivo.
# Empate: se elige el voto de la primera persona, informado en pantalla.
func cast_vote(choice: int) -> bool:
    if is_failed() or completed:
        return false
    pending_votes.append(clampi(choice,0,2))
    if pending_votes.size() < crew_size:
        save_game()
        return false
    var totals: Array = [0,0,0]
    for vote in pending_votes:
        totals[int(vote)] += 1
    var selected: int = int(pending_votes[0])
    for i in range(3):
        if int(totals[i]) > int(totals[selected]):
            selected = i
    make_decision(selected)
    return true

# Operaciones numéricas con datos NASA NSSDC; independiente de la telemetría.
func register_dataset_choice(option: int) -> void:
    const Facts = preload("res://scripts/planetary_facts.gd")
    if dataset_done or not science_done or dataset_answers.size() >= 3:
        return
    var index: int = dataset_answers.size()
    dataset_answers.append(option)
    var earned: int = Facts.score(option,mission_id,index)
    dataset_points += earned
    if earned > 0:
        dataset_correct += 1
    dataset_done = dataset_answers.size() >= 3
    if dataset_done and not is_failed() and not flight_state.is_empty():
        flight_state["dataset_points"] = dataset_points
        flight_state["dataset_done"] = true
    save_game()
