extends Node
class_name CentralHubSaveManager

enum WardenFightState {
    PRE_FIGHT,
    FIGHT,
    POST_FIGHT,
}

var warden_fight_state: int = WardenFightState.PRE_FIGHT

onready var _central_hub = get_parent()
onready var _save_key: String = get_parent().get_path()

func get_save_data() -> Array:
    return [_save_key, {
        'warden_fight_state': warden_fight_state
    }]

func load_version_0_1_0(all_save_data: Dictionary) -> void:
    if not _save_key in all_save_data:
        return

    var central_hub_save_data: Dictionary = all_save_data[_save_key]
    assert('warden_fight_state' in central_hub_save_data)

    warden_fight_state = central_hub_save_data['warden_fight_state']

    # Regardless of what state we're in, the camera focus point should always
    # start out as active and only deactivate as part of the intro fight
    # cutscene.
    _central_hub.get_camera_focus_point().set_active(true)

    match warden_fight_state:
        WardenFightState.PRE_FIGHT:
            # Before the warden fight has been triggered, disable both the triggers
            # and the walls. The central lock switch cutscene will handle enabling
            # the triggers, and the triggers will handle enabling the walls.
            _central_hub.set_enable_boss_fight_triggers(false)
            _central_hub.set_enable_boss_fight_walls(false)

            # Make sure fragile platform is there.
            _central_hub.get_fragile_platform().reset()

        WardenFightState.FIGHT:
            # If we're loading in and about to fight the warden (e.g. player died,
            # quit out, and then started again), enable the triggers.
            _central_hub.set_enable_boss_fight_triggers(true)
            _central_hub.set_enable_boss_fight_walls(false)

            # Make sure fragile platform is there.
            _central_hub.get_fragile_platform().reset()

        WardenFightState.POST_FIGHT:
            # Once we've beaten the warden, disable the triggers and walls.
            _central_hub.set_enable_boss_fight_triggers(false)
            _central_hub.set_enable_boss_fight_walls(false)

            # Make sure fragile platform is not there.
            _central_hub.get_fragile_platform().queue_free()