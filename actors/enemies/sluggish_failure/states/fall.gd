extends 'res://actors/enemies/state.gd'

var _velocity := Vector2.ZERO
var _player: Player

func enter(failure: SluggishFailure, previous_state_dict: Dictionary) -> void:
    _velocity = Vector2.ZERO
    _player = Util.get_player()

func exit(failure: SluggishFailure) -> void:
    pass

func update(failure: SluggishFailure, delta: float) -> Dictionary:
    var physics_manager := failure.get_physics_manager()

    # Use the player's gravity value for failure as well.
    #
    # TODO: Is this the best way of doing this? Maybe there's an
    #       inheritance-based solution that doesn't need to query the player's
    #       gravity directly (e.g. further split PhysicsManager into
    #       GroundedPhysicsManager and FlyingPhysicsManager and put player
    #       values as default in GroundedPhysicsManager so that the failure
    #       would just call get_gravity() or something).
    var gravity := _player.get_physics_manager().get_gravity()

    if failure.is_on_floor():
        failure.emit_dust_puff()
        return {'new_state': SluggishFailure.State.WALK}

    _velocity.y = min(
        _velocity.y + gravity * delta, physics_manager.get_terminal_velocity())
    failure.move(_velocity)

    return {'new_state': SluggishFailure.State.NO_CHANGE}
