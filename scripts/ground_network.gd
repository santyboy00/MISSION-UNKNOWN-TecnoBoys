extends RefCounted
# NASA DSN sites are factual. These operations plans, costs and bonuses are GAME RULES.
# https://science.nasa.gov/learn/basics-of-space-flight/chapter18-1/
const PLANS = [
 {"name":"ECONÓMICO · 1 VENTANA", "cost":0, "comm":0, "capacity":9, "description":"Enlaces simulados limitados; menor costo."},
 {"name":"EQUILIBRADO · 2 VENTANAS", "cost":9, "comm":8, "capacity":16, "description":"Buena relación costo / datos enviados."},
 {"name":"REFORZADO · 3 VENTANAS", "cost":19, "comm":16, "capacity":27, "description":"Mayor capacidad de recepción; mayor costo."}
]
const SITES = ["Goldstone (California, EE. UU.)", "Madrid (España)", "Canberra (Australia)"]
static func plan(i: int) -> Dictionary:
 return PLANS[clampi(i,0,2)]
