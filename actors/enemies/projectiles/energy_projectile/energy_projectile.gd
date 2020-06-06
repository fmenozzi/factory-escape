extends Node2D

export(float) var speed_tiles_per_second := 16.0

var _velocity := Vector2.ZERO

onready var _hitbox: Area2D = $Hitbox

func _ready() -> void:
    set_physics_process(false)

    # Detect impacts with both the environment (StaticBody2D) and the player's
    # hurtbox (Area2D).
    _hitbox.connect('body_entered', self, '_on_impact')
    _hitbox.connect('area_entered', self, '_on_impact')

func _physics_process(delta: float) -> void:
    position += _velocity * delta

func start(direction: Vector2) -> void:
    _velocity = direction * speed_tiles_per_second * Util.TILE_SIZE
    set_physics_process(true)

func _on_impact(_player_or_environment: Node) -> void:
    queue_free()
