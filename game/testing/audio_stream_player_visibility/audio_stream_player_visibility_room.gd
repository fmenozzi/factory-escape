extends Room

const SPEED := Util.TILE_SIZE * 4

onready var obj_vis: VisibilityNotifier2D = $Sprite/AudioStreamPlayerVisibility/ObjectVisibility
onready var att_vis: VisibilityNotifier2D = $Sprite/AudioStreamPlayerVisibility/AttenuationVisibility

onready var obj_rad: float = obj_vis.rect.size.x / 2.0
onready var att_rad: float = att_vis.rect.size.x / 2.0

func _draw() -> void:
    draw_rect(Rect2($Sprite.position - Vector2(obj_rad, obj_rad), obj_vis.rect.size), Color.red, false)
    draw_rect(Rect2($Sprite.position - Vector2(att_rad, att_rad), att_vis.rect.size), Color.blue, false)

func _process(delta: float) -> void:
    var direction := Vector2(
        int(Input.is_key_pressed(KEY_D)) - int(Input.is_key_pressed(KEY_A)),
        int(Input.is_key_pressed(KEY_S)) - int(Input.is_key_pressed(KEY_W)))

    $Sprite.position += direction.normalized() * SPEED * delta

    update()
