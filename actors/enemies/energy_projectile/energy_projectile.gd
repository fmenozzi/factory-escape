extends Node2D

export(float) var speed_tiles_per_second := 8.0

var _velocity := Vector2.ZERO

onready var _hitbox: Area2D = $Hitbox

func _ready() -> void:
    set_physics_process(false)

    _hitbox.connect('body_entered', self, '_on_impact')

func _physics_process(delta: float) -> void:
    position += _velocity * delta

func start(direction: Vector2) -> void:
    _velocity = direction.normalized() * speed_tiles_per_second * Util.TILE_SIZE
    set_physics_process(true)

func _on_impact(body: Node) -> void:
    queue_free()
