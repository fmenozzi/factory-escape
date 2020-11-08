extends Room

const ROTATION_SPEED_DEG := 45.0

onready var _laser = $BetterLaser
onready var _shoot_timer: Timer = $ShootTimer

func _ready() -> void:
    _shoot_timer.one_shot = false
    _shoot_timer.process_mode = Timer.TIMER_PROCESS_PHYSICS
    _shoot_timer.wait_time = 4.0
    _shoot_timer.connect('timeout', self, '_on_timeout')
    _shoot_timer.start()

    $BetterLaser.shoot()

func _unhandled_input(event):
    if event.is_action_pressed('ui_accept'):
        print('cancelling')
        $BetterLaser.cancel()

func _physics_process(delta: float) -> void:
    #return
    $BetterLaser.rotate(deg2rad(ROTATION_SPEED_DEG) * delta)

func _on_timeout() -> void:
    $BetterLaser.shoot()
