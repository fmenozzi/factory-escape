extends StaticBody2D

# The time in seconds that the platform spends in its collapsed state before
# resetting itself.
const COLLAPSED_DURATION: float = 2.0

# The time in seconds that the platform will wait for, once the player lands on
# it, until collapsing. The platform will flash during this period as a visual
# indicator for the player.
const WARNING_DURATION: float = 1.0

onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var _trigger_area: Area2D = $TriggerArea
onready var _flash_manager: Node = $FlashManager

var _active: bool = true

func _ready() -> void:
    _trigger_area.connect('body_entered', self, '_on_player_contact')

    _flash_manager.set_total_duration(WARNING_DURATION)

func _on_player_contact(player: Player) -> void:
    if not player:
        return

    # If platform is not active (i.e. it has already collapsed), deactivate it
    # to prevent the player from triggering the collapse again while it's
    # already collapsed.
    if not _active:
        return

    _active = false

    # Wait for the flashing to finish before collapsing the platform.
    _flash_manager.start_flashing()
    yield(_flash_manager, 'flashing_finished')
    _animation_player.play('collapse')

    # Once the animation finishes, wait for the collapse time to run out before
    # resetting the platform.
    yield(_animation_player, 'animation_finished')
    yield(get_tree().create_timer(COLLAPSED_DURATION), 'timeout')
    _animation_player.play_backwards('collapse')

    # Once that animation finishes, mark the platform as active so that the
    # player can interact with it again.
    yield(_animation_player, 'animation_finished')
    _active = true