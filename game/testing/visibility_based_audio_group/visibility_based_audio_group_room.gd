extends Room

const SPEED := Util.TILE_SIZE * 4

onready var obj_vis: VisibilityNotifier2D = $Sprite/VisibilityBasedAudioGroup/ObjectVisibility
onready var att_vis: VisibilityNotifier2D = $Sprite/VisibilityBasedAudioGroup/AttenuationVisibility

onready var obj_rad: float = obj_vis.rect.size.x / 2.0
onready var att_rad: float = att_vis.rect.size.x / 2.0

var _muted := false

func _ready() -> void:
    $Sprite/VisibilityBasedAudioGroup.get_player_by_name('BeepBeep').play()

func _draw() -> void:
    draw_rect(Rect2($Sprite.position - Vector2(obj_rad, obj_rad), obj_vis.rect.size), Color.red, false)
    draw_rect(Rect2($Sprite.position - Vector2(att_rad, att_rad), att_vis.rect.size), Color.blue, false)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and event.scancode == KEY_M:
        _muted = not _muted
        $Sprite/VisibilityBasedAudioGroup.set_muted(_muted)

func _process(delta: float) -> void:
    var direction := Vector2(
        int(Input.is_key_pressed(KEY_D)) - int(Input.is_key_pressed(KEY_A)),
        int(Input.is_key_pressed(KEY_S)) - int(Input.is_key_pressed(KEY_W)))

    $Sprite.position += direction.normalized() * SPEED * delta

    update()
