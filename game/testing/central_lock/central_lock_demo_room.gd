extends RoomFe

onready var _central_lock: CentralLock = $CentralLock

func _unhandled_input(event: InputEvent) -> void:
    if not (event is InputEventKey and event.pressed):
        return

    match event.scancode:
        KEY_1:
            _central_lock.turn_on_light(CentralLock.LockLight.UPPER_LEFT)

        KEY_2:
            _central_lock.turn_on_light(CentralLock.LockLight.UPPER_RIGHT)

        KEY_3:
            _central_lock.turn_on_light(CentralLock.LockLight.LOWER_LEFT)

        KEY_4:
            _central_lock.turn_on_light(CentralLock.LockLight.LOWER_RIGHT)

        KEY_5:
            _central_lock.turn_on_light(CentralLock.LockLight.CENTRAL)

        KEY_6:
            _central_lock.pulse_all_lights()
