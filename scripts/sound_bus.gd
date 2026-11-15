extends Node
# Audios originales generados para este juego. No requieren plugins.
const CLICK = preload("res://assets/audio/click.wav")
const ALERT = preload("res://assets/audio/alert.wav")
const LAUNCH = preload("res://assets/audio/launch.wav")
const EVENT_SOUNDS = {
    "thrusters": preload("res://assets/audio/thrusters.wav"),
    "eclipse": preload("res://assets/audio/eclipse.wav"),
    "signal": preload("res://assets/audio/signal.wav"),
    "thermal": preload("res://assets/audio/thermal.wav"),
    "meteors": preload("res://assets/audio/meteors.wav"),
    "radiation": preload("res://assets/audio/radiation.wav"),
    "autopilot": preload("res://assets/audio/autopilot.wav"),
    "science": preload("res://assets/audio/science.wav"),
    "calibration": preload("res://assets/audio/calibration.wav"),
    "downlink": preload("res://assets/audio/downlink.wav"),
    "failure": preload("res://assets/audio/failure.wav")
}
var ui_audio: AudioStreamPlayer
var effect_audio: AudioStreamPlayer
func _ready() -> void:
    ui_audio = AudioStreamPlayer.new()
    ui_audio.volume_db = -16.0
    add_child(ui_audio)
    effect_audio = AudioStreamPlayer.new()
    effect_audio.volume_db = -10.0
    add_child(effect_audio)
func play_sound(sound: AudioStream) -> void:
    ui_audio.stop()
    ui_audio.stream = sound
    ui_audio.play()
func play_click() -> void:
    play_sound(CLICK)
func play_alert() -> void:
    play_sound(ALERT)
func play_launch() -> void:
    play_sound(LAUNCH)
func play_event(event_id: String) -> void:
    var chosen: AudioStream = EVENT_SOUNDS.get(event_id, ALERT)
    effect_audio.stop()
    effect_audio.stream = chosen
    effect_audio.play()
