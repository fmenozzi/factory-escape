extends StaticBody2D

const COLLAPSED_DURATION: float = 2.0

onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var _trigger_area: Area2D = $TriggerArea
onready var _reset_timer: Timer = $ResetTimer

var _active: bool = true

func _ready() -> void:
    _trigger_area.connect('body_entered', self, '_on_player_contact')

    _reset_timer.wait_time = COLLAPSED_DURATION
    _reset_timer.one_shot = true
    _reset_timer.connect('timeout', self, '_on_reset_timeout')

func _on_player_contact(player: Player) -> void:
    if not player:
        return

    # If platform is not active (i.e. it has already collapsed), deactivate it
    # to prevent the player from triggering the collapse again while it's
    # already collapsed.
    if not _active:
        return
    _active = false

    # Once the collapse animation finishes, start the reset timer.
    _animation_player.play('collapse')
    yield(_animation_player, 'animation_finished')
    _reset_timer.start()

func _on_reset_timeout() -> void:
    # Reset the platform and reactivate platform.
    _animation_player.play_backwards('collapse')
    yield(_animation_player, 'animation_finished')
    _active = true