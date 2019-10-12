extends Area2D

var _player: Player = null

func _ready() -> void:
    self.connect('body_entered', self, '_on_player_entered')
    self.connect('body_exited', self, '_on_player_exited')

    set_process(false)

func _process(delta: float) -> void:
    if _player and _player.is_on_ground():
        _player.set_hazard_checkpoint(self.global_position)
        set_process(false)

func _on_player_entered(player: Player) -> void:
    if not player:
        return

    _player = player
    set_process(true)

func _on_player_exited(player: Player) -> void:
    if not player:
        return

    set_process(false)