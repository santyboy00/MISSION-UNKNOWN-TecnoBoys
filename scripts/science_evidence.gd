extends RefCounted
# El archivo contiene resúmenes de hallazgos publicados por NASA, NO datos crudos.
const PATH = "res://data/science_evidence_nasa.json"
static func all_data() -> Dictionary:
    var f: FileAccess = FileAccess.open(PATH, FileAccess.READ)
    if f == null:
        return {}
    var d = JSON.parse_string(f.get_as_text())
    return d if d is Dictionary else {}

static func for_mission(mission_id: int) -> Array:
    var all = all_data()
    var key: String = ["moon", "venus", "mars"][clampi(mission_id,0,2)]
    return all.get("missions",{}).get(key,[])

static func compatible(item: Dictionary, installed: Array) -> bool:
    return str(item.get("instrument", "")) in installed

static func observation_score(item: Dictionary, choice: int, installed: Array) -> int:
    if choice != int(item["answer"]):
        return 0
    return 10 if compatible(item,installed) else 3
