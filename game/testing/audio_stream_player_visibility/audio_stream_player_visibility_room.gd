extends Room

const SPEED := Util.TILE_SIZE * 4

onready var obj_vis: VisibilityNotifier2D = $Sprite/AudioStreamPlayerVisibility/ObjectVisibility
onready var att_vis: VisibilityNotifier2D = $Sprite/AudioStreamPlayerVisibility/AttenuationVisibility

func _ready() -> void:
    print("obj rect (pos, size): %s, %s" % [obj_vis.rect.position, obj_vis.rect.size])
    print("att rect (pos, size): %s, %s" % [att_vis.rect.position, att_vis.rect.size])

func _process(delta: float) -> void:
    var direction := Vector2(
        int(Input.is_key_pressed(KEY_D)) - int(Input.is_key_pressed(KEY_A)),
        int(Input.is_key_pressed(KEY_S)) - int(Input.is_key_pressed(KEY_W)))

    $Sprite.position += direction.normalized() * SPEED * delta
