extends 'res://actors/enemies/enemy_state.gd'

const TIME_BETWEEN_SHOTS: float = 0.35
const NUM_SHOTS_IN_VOLLEY: int = 3

onready var _shoot_timer: Timer = $ShootTimer

var _player: Player
var _num_shots_fired

func _ready() -> void:
    _shoot_timer.one_shot = false
    _shoot_timer.wait_time = TIME_BETWEEN_SHOTS

func enter(turret: Turret, previous_state_dict: Dictionary) -> void:
    _player = Util.get_player()
    _num_shots_fired = 0

    # Hide scan line.
    turret.get_scanner().visible = false

    _shoot_timer.connect('timeout', self, '_shoot', [turret])
    _shoot_timer.start()

func exit(turret: Turret) -> void:
    # Show scan line.
    turret.get_scanner().visible = true

func update(turret: Turret, delta: float) -> Dictionary:
    if _shoot_timer.is_stopped():
        return {'new_state': Turret.State.PAUSE}

    return {'new_state': Turret.State.NO_CHANGE}

func _shoot(turret: Turret) -> void:
    turret.shoot()
    _num_shots_fired += 1
    if _num_shots_fired == NUM_SHOTS_IN_VOLLEY:
        _shoot_timer.stop()
