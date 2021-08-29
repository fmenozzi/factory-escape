extends Room

onready var _closing_door_left: StaticBody2D = $ClosingDoorLeft
onready var _closing_door_right: StaticBody2D = $ClosingDoorRight
onready var _door_trigger: Area2D = $ClosingDoorTrigger
onready var _ability_chosen_sound: AudioStreamPlayer = $AbilityChosenSound

func _ready() -> void:
    _door_trigger.connect('body_entered', self, '_on_player_entered_room')

func open_doors_and_keep_them_open() -> void:
    _closing_door_left.set_opened()
    _closing_door_right.set_opened()

    _door_trigger.disconnect('body_entered', self, '_on_player_entered_room')

func _on_player_entered_room(player: Player) -> void:
    if not player:
        return

    _closing_door_left.close()
    _closing_door_right.close()

    # As of 3.2 we need to use call_deferred here.
    _door_trigger.call_deferred(
        'disconnect', 'body_entered', self, '_on_player_entered_room')

func _on_ability_chosen(chosen_ability: int) -> void:
    # Play the ability chosen sound. Wait a specific amount of time before
    # opening the doors (corresponding to the time it takes for most of the
    # sound to finish, as there is "empty space" due to things like reverb and
    # echo).
    MusicPlayer.fade_out(MusicPlayer.Music.WORLD_BASE, 0.5)
    _ability_chosen_sound.play()
    yield(get_tree().create_timer(3.5), 'timeout')
    MusicPlayer.fade_in(MusicPlayer.Music.WORLD_BASE, 3.0)

    _closing_door_left.open()
    _closing_door_right.open()
