extends KinematicBody2D

onready var _health: Health = $Health
onready var _flash_manager: Node = $FlashManager

func _ready() -> void:
    $AnimationPlayer.play('idle')

func take_hit(damage: int, player: Player) -> void:
    _health.take_damage(damage)
    _flash_manager.start_flashing()
