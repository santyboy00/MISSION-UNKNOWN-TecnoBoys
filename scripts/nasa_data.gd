extends RefCounted
## Datos PUBLICADOS por NASA/JPL y cálculos idealizados separados de reglas lúdicas.
## Referencias y fecha de consulta en res://data/nasa_reference.json.
const EARTH_AU: float = 1.00000261
const VENUS_AU: float = 0.72333566
const MARS_AU: float = 1.52371034
const YEAR_DAYS: float = 365.256
const EARTH_ORBIT_SPEED_KMS: float = 29.78
const MOON_DISTANCE_KM: float = 384400.0
const MOON_REFERENCE_DAYS: float = 3.0
const SOLAR_AT_1AU: float = 1360.8
const LIGHT_KM_S: float = 299792.458
const AU_KM: float = 149597870.7

static func orbit_au(mission_id: int) -> float:
    match mission_id:
        1: return VENUS_AU
        2: return MARS_AU
        _: return EARTH_AU

static func ideal_transfer_days(mission_id: int) -> float:
    if mission_id == 0:
        # Referencia de Apollo. No se aplica Hohmann heliocéntrico a la Luna.
        return MOON_REFERENCE_DAYS
    # Medio período de transferencia de Hohmann, 2 cuerpos, órbitas circulares.
    var transfer_a_au: float = (EARTH_AU + orbit_au(mission_id)) * 0.5
    return 0.5 * YEAR_DAYS * sqrt(pow(transfer_a_au, 3.0))

static func ideal_departure_delta_v_kms(mission_id: int) -> float:
    if mission_id == 0:
        return 0.0  # No aplica esta transferencia heliocéntrica a la Luna.
    var destination: float = orbit_au(mission_id)
    var transfer_speed: float = EARTH_ORBIT_SPEED_KMS * sqrt(2.0 * destination / (EARTH_AU + destination))
    return absf(transfer_speed - EARTH_ORBIT_SPEED_KMS)

static func solar_flux_wm2(mission_id: int) -> float:
    # NASA/JPL Education: ley inversa del cuadrado; distancia orbital promedio.
    var distance: float = orbit_au(mission_id)
    return SOLAR_AT_1AU / (distance * distance)

static func solar_ratio(mission_id: int) -> float:
    return solar_flux_wm2(mission_id) / SOLAR_AT_1AU

static func lunar_signal_seconds() -> float:
    # Un solo sentido. Media geométrica, no latencia total de un sistema real.
    return MOON_DISTANCE_KM / LIGHT_KM_S

static func heliocentric_light_minutes(mission_id: int) -> float:
    # Tiempo de luz DESDE EL SOL, no desde la Tierra.
    return orbit_au(mission_id) * AU_KM / LIGHT_KM_S / 60.0

static func physics_summary(mission_id: int) -> String:
    if mission_id == 0:
        return "NASA: 384 400 km a la Luna · viaje de referencia %.0f días · retardo de señal aprox. %.2f s (una vía)" % [MOON_REFERENCE_DAYS, lunar_signal_seconds()]
    return "NASA/JPL: %.3f UA · Hohmann ideal %.0f días · Δv solar %.2f km/s · irradiancia %.0f W/m²" % [orbit_au(mission_id), ideal_transfer_days(mission_id), ideal_departure_delta_v_kms(mission_id), solar_flux_wm2(mission_id)]

static func limitation() -> String:
    return "Referencia: NASA/JPL. Hohmann usa órbitas circulares ideales; NO modela fechas de salida, captura, delta-v real ni perturbaciones."

# Ecuación ideal de Tsiolkovski. Masa seca y propelente son HIPÓTESIS
# del vehículo ficticio; los parámetros de JPL no describen este lanzador.
static func rocket_delta_v_mps(dry_mass_kg: float, propellant_kg: float, isp_s: float = 320.0) -> float:
    if dry_mass_kg <= 0.0 or propellant_kg <= 0.0 or isp_s <= 0.0:
        return 0.0
    return isp_s * 9.80665 * log((dry_mass_kg + propellant_kg) / dry_mass_kg)

static func panel_watts(distance_au: float, area_m2: float = 0.50, efficiency: float = 0.27) -> float:
    if distance_au <= 0.0:
        return 0.0
    return SOLAR_AT_1AU / (distance_au * distance_au) * area_m2 * efficiency

static func one_way_light_time_extremes_minutes(mission_id: int) -> Vector2:
    if mission_id == 0:
        return Vector2(lunar_signal_seconds()/60.0, lunar_signal_seconds()/60.0)
    # Mínimo y máximo geométricos de órbitas circulares: NO distancias en una fecha concreta.
    var destination: float = orbit_au(mission_id)
    var min_distance: float = absf(EARTH_AU-destination) * AU_KM
    var max_distance: float = (EARTH_AU+destination) * AU_KM
    return Vector2(min_distance/LIGHT_KM_S/60.0,max_distance/LIGHT_KM_S/60.0)
