extends KinematicBody2D

onready var _health: Health = $Health
onready var _flash_manager: Node = $FlashManager
onready var _animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
    _animation_player.play('idle')

    _health.connect('health_changed', self, '_on_health_changed')
    _health.connect('died', self, '_on_died')

func take_hit(damage: int, player: Player) -> void:
    _health.take_damage(damage)
    _flash_manager.start_flashing()

func _on_health_changed(old_health: int, new_health: int) -> void:
    print('WORKER DRONE HIT (new health: ', new_health, ')')

# TODO: Make death nicer (animation, effects, etc.).
func _on_died() -> void:
    print('WORKER DRONE DIED')
    queue_free()
