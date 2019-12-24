extends Area2D

onready var _player: Player = Util.get_player()

func _ready() -> void:
    self.connect('body_entered', self, '_on_player_entered')
    self.connect('body_exited', self, '_on_player_exited')

    set_process(false)

func _process(delta: float) -> void:
    if _player.is_on_ground():
        _player.set_hazard_checkpoint(self)
        set_process(false)

func _on_player_entered(player: Player) -> void:
    if not player:
        return

    set_process(true)

func _on_player_exited(player: Player) -> void:
    if not player:
        return

    set_process(false)